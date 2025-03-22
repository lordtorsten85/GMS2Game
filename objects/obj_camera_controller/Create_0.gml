// obj_camera_controller - Create Event
// Sets up the camera with a logical resolution and viewport size.
// Configures fullscreen or windowed mode and maintains aspect ratio.

// Define logical resolution (internal camera size)
global.cam_width = 640;
global.cam_height = 360;

// Create a camera and set its view size
global.cam = camera_create();
camera_set_view_size(global.cam, global.cam_width, global.cam_height);
camera_set_view_pos(global.cam, 0, 0); // Initial position at (0,0)

// Enable view[0] with the new camera
view_enabled = true;
view_visible[0] = true;
view_camera[0] = global.cam;

// Set window size (non-fullscreen)
window_set_fullscreen(true);
window_set_size(1280, 720);
surface_resize(application_surface, 1280, 720);
display_set_gui_size(1280, 720); // Explicitly set GUI size to match window