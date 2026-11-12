#pragma once

#import <QuartzCore/QuartzCore.h>

typedef struct {
    bool (*gl4metalInit)(void);
    void (*glMakeCurrent)(void *metalLayerPtr);
    void (*glSwapBuffers)(void);
    // void (*glSwapInterval)(int interval);
} mgl_library;

typedef struct {
    void *layer;
    void *context;
} mgl_render_window_t;

void set_mgl_bridge_tbl();