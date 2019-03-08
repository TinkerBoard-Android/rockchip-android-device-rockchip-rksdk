/*
 * Copyright 2018 Fuzhou Rockchip Electronics Co. LTD
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#define LOG_TAG "RKATVAudioPolicyManager"
//#define LOG_NDEBUG 0
#include <media/AudioParameter.h>
#include <media/mediarecorder.h>
#include <utils/Log.h>
#include <utils/String16.h>
#include <utils/String8.h>
#include <utils/StrongPointer.h>
#include <cutils/properties.h>

#include "ATVAudioPolicyManager.h"


namespace android {

// ---  class factory
extern "C" AudioPolicyInterface* createAudioPolicyManager(
        AudioPolicyClientInterface *clientInterface)
{
    ALOGD("%s: RKATVAudioPolicyManager ",__FUNCTION__);
    return new ATVAudioPolicyManager(clientInterface);
}

extern "C" void destroyAudioPolicyManager(AudioPolicyInterface *interface)
{
    delete interface;
}

ATVAudioPolicyManager::ATVAudioPolicyManager(
        AudioPolicyClientInterface *clientInterface)
    : AudioPolicyManager(clientInterface)
{
    ALOGD("%s",__FUNCTION__);
    mBitstreamDevice = AUDIO_DEVICE_NONE;
}

bool ATVAudioPolicyManager::isAlreadConnect(audio_devices_t device,
                                            audio_policy_dev_state_t state,
                                            const char *device_address,
                                            const char *device_name)
{
    // if device already in mAvailableOutputDevices, just return NO_ERROR
    sp<DeviceDescriptor> devDesc =
            mHwModules.getDeviceDescriptor(device, device_address, device_name);
    if (audio_is_output_device(device)) {
        ssize_t index = mAvailableOutputDevices.indexOf(devDesc);
        if(state == AUDIO_POLICY_DEVICE_STATE_AVAILABLE){
            if (index >= 0) {
                return true;
            }
        }
    }

    return false;
}

/*
 * set device for audio pass throught/bitstream (HDMI or spdif)
 * there is no interface for android to set bitstream device
 * we reusing setDeviceConnectionState to set the bitsteram device,
 * if device_name = "RK_SET_BITSTREAM_DEVICE", then set the bitstream device
 */
status_t ATVAudioPolicyManager::setBitStreamDevice(audio_devices_t device,audio_policy_dev_state_t state,
                             const char *device_address,const char *device_name)
{
    const char* setBitstreamDevice = "RK_SET_BITSTREAM_DEVICE";
    (void*)device_address;
    if((device_name != NULL) && (strcmp(device_name,setBitstreamDevice) == 0)){
        audio_devices_t newDevice = mBitstreamDevice;
        if((device == AUDIO_DEVICE_OUT_AUX_DIGITAL) && (state == AUDIO_POLICY_DEVICE_STATE_AVAILABLE)){
            newDevice = AUDIO_DEVICE_OUT_AUX_DIGITAL;
        }else if((device == AUDIO_DEVICE_OUT_SPDIF) && (state == AUDIO_POLICY_DEVICE_STATE_AVAILABLE)){
            newDevice = AUDIO_DEVICE_OUT_SPDIF;
        }

        if((device == AUDIO_DEVICE_OUT_AUX_DIGITAL) || (device == AUDIO_DEVICE_OUT_SPDIF)){
            // if device is changed, the surround format need clear
            if(mBitstreamDevice != newDevice){
                mBitstreamDevice = newDevice;
            }
            bool already = isAlreadConnect(device,state,device_address,device_name);
            if(already){
                return NO_ERROR;
            }
            return AudioPolicyManager::setDeviceConnectionState(device, state, device_address, device_name);
        }
    }

    return -1;
}

status_t ATVAudioPolicyManager::setDeviceConnectionState(audio_devices_t device,
                                                         audio_policy_dev_state_t state,
                                                         const char *device_address,
                                                         const char *device_name)
{
    ALOGD("setDeviceConnectionState() this= %p, device: 0x%X, state %d, address %s name %s",
            this,device, state, device_address, device_name);

    if (!audio_is_output_device(device) && !audio_is_input_device(device)) return BAD_VALUE;

    if(setBitStreamDevice(device,state,device_address,device_name) == NO_ERROR) {
        return NO_ERROR;
    }

    /*
     * some device may be set connect already(For example: HDMI/SPDIF set connect for audio bitstream/pass throught by AudioSetting),
     * so we just return NO_ERROR to tell AudioService or App this device is connect success
     */
    bool already = isAlreadConnect(device,state,device_address,device_name);
    if(already){
        ALOGD("setDeviceConnectionState() device already connected: %x", device);
        return NO_ERROR;
    }

    return AudioPolicyManager::setDeviceConnectionState(device, state, device_address, device_name);
}

audio_policy_dev_state_t ATVAudioPolicyManager::getDeviceConnectionState(audio_devices_t device,
                                              const char *device_address)
{
 //   ALOGD("%s: device = %d,device_address = %p",__FUNCTION__,(int)device,device_address);
    const char* getBitstreamDevice = "RK_GET_BITSTREAM_DEVICE";
    if((device_address != NULL) && (strcmp(device_address,getBitstreamDevice) == 0)){
        if((device == AUDIO_DEVICE_OUT_AUX_DIGITAL)
            && (mBitstreamDevice == AUDIO_DEVICE_OUT_AUX_DIGITAL)){
            return AUDIO_POLICY_DEVICE_STATE_AVAILABLE;
        }else if((device == AUDIO_DEVICE_OUT_SPDIF)
            && (mBitstreamDevice == AUDIO_DEVICE_OUT_SPDIF)){
            return AUDIO_POLICY_DEVICE_STATE_AVAILABLE;
        }

        return AUDIO_POLICY_DEVICE_STATE_UNAVAILABLE;
    }

    return AudioPolicyManager::getDeviceConnectionState(device,device_address);
}

/*
 * getOutputForDevice is a prviate function in AudioPolicyManager
 * we can't call it
 */
audio_io_handle_t ATVAudioPolicyManager::getOutputForDevice(
        audio_devices_t device,
        audio_session_t session,
        audio_stream_type_t stream,
        const audio_config_t *config,
        audio_output_flags_t *flags)
{
    audio_io_handle_t output = AUDIO_IO_HANDLE_NONE;
    status_t status;

    /* select one device to bitstream audio
     * we support HDMI/SPDIF to bitsteam audio, if flag = AUDIO_OUTPUT_FLAG_DIRECT and
     * audio format is AUDIO_FORMAT_IEC61937, we think it want to bitstream a audio
     */
    if((*flags & AUDIO_OUTPUT_FLAG_DIRECT) && (config->format == AUDIO_FORMAT_IEC61937)){
        audio_devices_t availableOutputDevicesType = mAvailableOutputDevices.types();
        ALOGD("%s: mBitstreamDevice = 0x%x,availableOutputDevicesType= 0x%x",__FUNCTION__,(int)mBitstreamDevice,(int)availableOutputDevicesType);
        if((mBitstreamDevice == AUDIO_DEVICE_OUT_SPDIF) &&
            (availableOutputDevicesType&AUDIO_DEVICE_OUT_SPDIF)){
            device = AUDIO_DEVICE_OUT_SPDIF;
        }else if((mBitstreamDevice == AUDIO_DEVICE_OUT_AUX_DIGITAL) &&
            (availableOutputDevicesType&AUDIO_DEVICE_OUT_AUX_DIGITAL)){
            device = AUDIO_DEVICE_OUT_AUX_DIGITAL;
        }
    }

    // open a direct output if required by specified parameters
    //force direct flag if offload flag is set: offloading implies a direct output stream
    // and all common behaviors are driven by checking only the direct flag
    // this should normally be set appropriately in the policy configuration file
    if ((*flags & AUDIO_OUTPUT_FLAG_COMPRESS_OFFLOAD) != 0) {
        *flags = (audio_output_flags_t)(*flags | AUDIO_OUTPUT_FLAG_DIRECT);
    }
    if ((*flags & AUDIO_OUTPUT_FLAG_HW_AV_SYNC) != 0) {
        *flags = (audio_output_flags_t)(*flags | AUDIO_OUTPUT_FLAG_DIRECT);
    }
    // only allow deep buffering for music stream type
    if (stream != AUDIO_STREAM_MUSIC) {
        *flags = (audio_output_flags_t)(*flags &~AUDIO_OUTPUT_FLAG_DEEP_BUFFER);
    } else if (/* stream == AUDIO_STREAM_MUSIC && */
            *flags == AUDIO_OUTPUT_FLAG_NONE &&
            property_get_bool("audio.deep_buffer.media", false /* default_value */)) {
        // use DEEP_BUFFER as default output for music stream type
        *flags = (audio_output_flags_t)AUDIO_OUTPUT_FLAG_DEEP_BUFFER;
    }
    if (stream == AUDIO_STREAM_TTS) {
        *flags = AUDIO_OUTPUT_FLAG_TTS;
    } else if (stream == AUDIO_STREAM_VOICE_CALL &&
               audio_is_linear_pcm(config->format)) {
        *flags = (audio_output_flags_t)(AUDIO_OUTPUT_FLAG_VOIP_RX |
                                       AUDIO_OUTPUT_FLAG_DIRECT);
        ALOGV("Set VoIP and Direct output flags for PCM format");
    } else if (device == AUDIO_DEVICE_OUT_TELEPHONY_TX &&
        stream == AUDIO_STREAM_MUSIC &&
        audio_is_linear_pcm(config->format) &&
        isInCall()) {
        *flags = (audio_output_flags_t)AUDIO_OUTPUT_FLAG_INCALL_MUSIC;
    }


    sp<IOProfile> profile;

    // skip direct output selection if the request can obviously be attached to a mixed output
    // and not explicitly requested
    if (((*flags & AUDIO_OUTPUT_FLAG_DIRECT) == 0) &&
            audio_is_linear_pcm(config->format) && config->sample_rate <= SAMPLE_RATE_HZ_MAX &&
            audio_channel_count_from_out_mask(config->channel_mask) <= 2) {
        ALOGD("%s: %d go to non_direct_output",__FUNCTION__,__LINE__);
        goto non_direct_output;
    }

    // Do not allow offloading if one non offloadable effect is enabled or MasterMono is enabled.
    // This prevents creating an offloaded track and tearing it down immediately after start
    // when audioflinger detects there is an active non offloadable effect.
    // FIXME: We should check the audio session here but we do not have it in this context.
    // This may prevent offloading in rare situations where effects are left active by apps
    // in the background.

    if (((*flags & AUDIO_OUTPUT_FLAG_COMPRESS_OFFLOAD) == 0) ||
            !(mEffects.isNonOffloadableEffectEnabled() || mMasterMono)) {
        profile = getProfileForDirectOutput(device,
                                           config->sample_rate,
                                           config->format,
                                           config->channel_mask,
                                           (audio_output_flags_t)*flags);
    }

    if (profile != 0) {
        ALOGD("%s: direct mode",__FUNCTION__);
        // exclusive outputs for MMAP and Offload are enforced by different session ids.
        for (size_t i = 0; i < mOutputs.size(); i++) {
            sp<SwAudioOutputDescriptor> desc = mOutputs.valueAt(i);
            if (!desc->isDuplicated() && (profile == desc->mProfile)) {
                // reuse direct output if currently open by the same client
                // and configured with same parameters
                if ((config->sample_rate == desc->mSamplingRate) &&
                    (config->format == desc->mFormat) &&
                    (config->channel_mask == desc->mChannelMask) &&
                    (session == desc->mDirectClientSession)) {
                    desc->mDirectOpenCount++;
                    ALOGI("getOutputForDevice() reusing direct output %d for session %d",
                        mOutputs.keyAt(i), session);
                    return mOutputs.keyAt(i);
                }
            }
        }

        if (!profile->canOpenNewIo()) {
            goto non_direct_output;
        }

        sp<SwAudioOutputDescriptor> outputDesc =
                new SwAudioOutputDescriptor(profile, mpClientInterface);

        DeviceVector outputDevices = mAvailableOutputDevices.getDevicesFromType(device);
        String8 address = outputDevices.size() > 0 ? outputDevices.itemAt(0)->mAddress
                : String8("");

        status = outputDesc->open(config, device, address, stream, *flags, &output);

        // only accept an output with the requested parameters
        if (status != NO_ERROR ||
            (config->sample_rate != 0 && config->sample_rate != outputDesc->mSamplingRate) ||
            (config->format != AUDIO_FORMAT_DEFAULT && config->format != outputDesc->mFormat) ||
            (config->channel_mask != 0 && config->channel_mask != outputDesc->mChannelMask)) {
            ALOGV("getOutputForDevice() failed opening direct output: output %d sample rate %d %d,"
                    "format %d %d, channel mask %04x %04x", output, config->sample_rate,
                    outputDesc->mSamplingRate, config->format, outputDesc->mFormat,
                    config->channel_mask, outputDesc->mChannelMask);
            if (output != AUDIO_IO_HANDLE_NONE) {
                outputDesc->close();
            }
            // fall back to mixer output if possible when the direct output could not be open
            if (audio_is_linear_pcm(config->format) &&
                    config->sample_rate  <= SAMPLE_RATE_HZ_MAX) {
                goto non_direct_output;
            }
            return AUDIO_IO_HANDLE_NONE;
        }
        outputDesc->mRefCount[stream] = 0;
        outputDesc->mStopTime[stream] = 0;
        outputDesc->mDirectOpenCount = 1;
        outputDesc->mDirectClientSession = session;

        addOutput(output, outputDesc);
        mPreviousOutputs = mOutputs;
        ALOGV("getOutputForDevice() returns new direct output %d", output);
        mpClientInterface->onAudioPortListUpdate();
        return output;
    }
non_direct_output:
    ALOGD("%s: mixer mode",__FUNCTION__);
    // A request for HW A/V sync cannot fallback to a mixed output because time
    // stamps are embedded in audio data
    if ((*flags & (AUDIO_OUTPUT_FLAG_HW_AV_SYNC | AUDIO_OUTPUT_FLAG_MMAP_NOIRQ)) != 0) {
        return AUDIO_IO_HANDLE_NONE;
    }

    // ignoring channel mask due to downmix capability in mixer

    // open a non direct output

    // for non direct outputs, only PCM is supported
    if (audio_is_linear_pcm(config->format)) {
        // get which output is suitable for the specified stream. The actual
        // routing change will happen when startOutput() will be called
        SortedVector<audio_io_handle_t> outputs = getOutputsForDevice(device, mOutputs);

        // at this stage we should ignore the DIRECT flag as no direct output could be found earlier
        *flags = (audio_output_flags_t)(*flags & ~AUDIO_OUTPUT_FLAG_DIRECT);
        output = selectOutput(outputs, *flags, config->format);
    }
    ALOGW_IF((output == 0), "getOutputForDevice() could not find output for stream %d, "
            "sampling rate %d, format %#x, channels %#x, flags %#x",
            stream, config->sample_rate, config->format, config->channel_mask, *flags);

    return output;
}
}  // namespace android
