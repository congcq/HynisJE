#import "mgl_bridge.h"
#import "SurfaceViewController.h"

#include <dlfcn.h>
#include "bridge_tbl.h"
#include "environ.h"
#include "utils.h"

static mgl_library handle;

void dlsym_GL() {
    void *dl_handle = dlopen("@rpath/libgl4metal.dylib", RTLD_GLOBAL);
    NSCAssert(dl_handle, @(dlerror()));
    handle.gl4metalInit = dlsym(dl_handle, "gl4metalInit");
    handle.glMakeCurrent = dlsym(dl_handle, "glMakeCurrent");
    handle.glSwapBuffers = dlsym(dl_handle, "glSwapBuffers");
    // handle.glSwapInterval = dlsym(dl_handle, "glSwapInterval");
}

static bool mgl_init() {
    dlsym_GL();
    return handle.gl4metalInit();
}

basic_render_window_t* mgl_init_context(basic_render_window_t *share) {
    mgl_render_window_t* bundle = calloc(1, sizeof(mgl_render_window_t));
    if (!bundle) return NULL;

    CAMetalLayer *layer = SurfaceViewController.surface.layer;
    bundle->layer = (__bridge void *)layer;
    bundle->context = (void *)1; // dummy value, as the context is managed by the Metal layer

    return (basic_render_window_t *)bundle;
}

void mgl_make_current(basic_render_window_t *bundle) {
    if (!bundle) {
        if (handle.glMakeCurrent) handle.glMakeCurrent(NULL);
        currentBundle = NULL;
        return;
    }

    mgl_render_window_t *mgl_bundle = (mgl_render_window_t *)bundle;
    if (handle.glMakeCurrent) {
        handle.glMakeCurrent(mgl_bundle->layer);
        currentBundle = bundle;
    }
}

void mgl_swap_buffers() {
    if (!currentBundle) return;

    if (handle.glSwapBuffers) handle.glSwapBuffers();
}

void mgl_swap_interval(int interval) {
    // if (handle.glSwapInterval) handle.glSwapInterval(interval);
}

void mgl_terminate() {
    // No specific termination needed for Metal context
}

void set_mgl_bridge_tbl() {
    br_init = mgl_init;
    br_init_context = (br_init_context_t) mgl_init_context;
    br_make_current = (br_make_current_t) mgl_make_current;
    br_swap_buffers = mgl_swap_buffers;
    br_swap_interval = mgl_swap_interval;
    br_terminate = mgl_terminate;
}