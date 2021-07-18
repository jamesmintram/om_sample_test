#include <foundation/allocator.h>
#include <foundation/api_registry.h>

#include <plugins/simulate/simulate_entry.h>

struct tm_simulate_state_o {
    // Store state here.

    tm_allocator_i *allocator;
};

static tm_simulate_state_o *start(tm_simulate_start_args_t *args)
{
    tm_simulate_state_o *state = tm_alloc(args->allocator, sizeof(*state));
    *state = (tm_simulate_state_o) {
        .allocator = args->allocator,
    };

    // Setup stuff at beginning of simulation.

    return state;
}

static void stop(tm_simulate_state_o *state)
{
    // Clean up when simulation ends.

    tm_allocator_i a = *state->allocator;
    tm_free(&a, state, sizeof(*state));
}

static void tick(tm_simulate_state_o *state, tm_simulate_frame_args_t *args)
{
    // Called once a frame.
}

static tm_simulate_entry_i simulate_entry_i = {
     // Change this and re-run hash.exe if you wish to change the unique identifier
    .id = TM_STATIC_HASH("tm_custom_simulate_entry", 0x201222bb97145e7ULL),
    .display_name = "Custom Simulate Entry",
    .start = start,
    .stop = stop,
    .tick = tick,
};

TM_DLL_EXPORT void tm_load_plugin(struct tm_api_registry_api* reg, bool load)
{
    tm_add_or_remove_implementation(reg, load, TM_SIMULATE_ENTRY_INTERFACE_NAME, &simulate_entry_i);
}
