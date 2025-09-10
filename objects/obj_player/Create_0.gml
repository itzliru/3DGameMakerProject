sensitivity = 0.1 //Mouse movement
max_spd = 2; //speed of character
acc = 0.1; //acelleration

fb_vel = 0; //forwards and backwards velocity
rl_vel = 0; //right and left
z_vel = 0;
jump_spd = 0;

depth = 0;
height = 32;
z = depth;
pitch = 0;
          
up_vel = 0;    

gpu_set_ztestenable(true);
gpu_set_zwriteenable(true);
// obj_player Create
direction = 0; // yaw (rotation around Z+)
pitch = 0;     // looking up/down
