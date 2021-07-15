/*
 * org_xiph_opus_decoderjni_OpusDecoder.h
 * Takes a opus bitstream from java callbacks from JNI and writes raw stereo PCM to the jni callbacks. Decodes simple and chained OggOpus files from beginning to end.
 *
 * (C) 2014 Radu Motisan, radu.motisan@gmail.com
 *
 * Part of the OpenPlayer implementation for Alpine Audio Now Digital LLC
 */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include "ogg.h"
#include "opus.h"
#include "opus_header.h"

typedef int (*WriteDecodedDataFunction)(int16_t* buf, int len, int amount);

#define BUFFER_LENGTH 4096

#ifndef _Included_org_xiph_opus_OpusDecoder
	#define _Included_org_xiph_opus_OpusDecoder
	#ifdef __cplusplus
	extern "C" {
	#endif

    __attribute__ ((visibility ("default")))
    void release();
    
    __attribute__ ((visibility ("default")))
    void prepare(WriteDecodedDataFunction writeDecodeFunction);
    
    __attribute__ ((visibility ("default")))
    int readDecodeWriteLoop(char* buf, int len);

	#ifdef __cplusplus
	}
	#endif
#endif
