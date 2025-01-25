#include "blizzard.as"
#include "..\\math\\math.as"
//#include "..\\world\\world.as"



namespace FPP {
    const Vector2 SCREEN_CENTER = Vector2(0.8/2, 0.6/2);

    class FirstPersonPlayer {
        Vector3 position;   // position in wc3 world (bound to wc3's map limits)
        Vector3 absolute_position;  // absolute position in world (not bound to wc3's map limits)
        World::WorldInstance@ world;

        Vector3 motion;

        float stepHeight = PLAYER_STEPHEIGHT;
        bool isSneaking;
        bool isSprinting;

        bool onGround;
        bool isCollidedHorizontally;
        bool isCollidedVertically;
        bool isCollided;

        bool waitingForChunksToLoad;    // movement is disabled while potentional collidable chunks are loading

        float eyePosition = PLAYER_DEFAULT_EYES_POSITION;
        float fov = PLAYER_DEFAULT_FOV;
        Vector2 targetFacing;
        Vector2 currentFacing;
        float facingSmoothFactor = 22.0f;

        float cameraTime = 0.05f;

        float speed = 4.0f;
        float cameraSpeed = 100.0f;

        int blockBreakCooldown = 0;

        private World::ChunkPos _currentChunk;

        void Init(World::WorldInstance@ world, const Vector3 &in position) {
            this.absolute_position = position;
            @this.world = @world;

            currentFacing = Vector2(0.0f, 0.0f);
            targetFacing = Vector2(0.0f, 0.0f);

            framehandle cursor = GetOriginFrame(ORIGIN_FRAME_CURSOR_FRAME, 0);
            SetFrameAlpha(cursor, 0);

            //_currentChunk = World::AbsolutePositionToChunkPos(absolute_position);
            //world.RequestChunk(_currentChunk);
        }

        void SetPosition(const Vector3 &in newPosition) {

            absolute_position = newPosition;
            // Vector3 pmin = Vector3(absolute_position.x - PLAYER_SIZE, absolute_position.y - PLAYER_SIZE, absolute_position.z - PLAYER_HEIGHT);
            // Vector3 pmax = Vector3(absolute_position.x + PLAYER_SIZE, absolute_position.y + PLAYER_SIZE, absolute_position.z + PLAYER_HEIGHT);
            
            // Collision::TestAABBWorld(Collision::AABB(pmin, pmax), world);
            // Vector3 mov = Collision::TestAABBWorld(Collision::AABB(pmin, pmax), world);
            // if(mov.Length() > 0.1f) {
            //     __debug("collided " + mov);
            // }

            Vector3 oldPos = position;
            position = World::AbsolutePositionToWC3Position(newPosition, false);

            if(Vector3Distance(oldPos, position) > 1000.0f) {
                SetCameraPosition(position.x, position.y);
                SetCameraField(CAMERA_FIELD_ZOFFSET, position.z, 0.0);
            }

        }

        void UpdateMovement() {
            Move(motion);
            if(waitingForChunksToLoad) return;

            motion.x = motion.x * 0.85f;
            motion.y = motion.y * 0.85f;
            //motion.z = motion.z * 0.8f;

            Vector3 oldPos = position;
            position = World::AbsolutePositionToWC3Position(absolute_position, false);

            float d = Vector3Distance(oldPos, position);
            if(d > 500.0f) {
                SetCameraPosition(position.x, position.y);
                SetCameraField(CAMERA_FIELD_ZOFFSET, position.z, 0.0);
            }
            if(d > 5000.0f) {
                world.UpdateBuiltChunksPositions();
            }
        }

        void SetCameraZ(float z) {
            float zz = GetCameraField(CAMERA_FIELD_ZOFFSET)+z-GetCameraTargetPositionZ();
            SetCameraField(CAMERA_FIELD_ZOFFSET,zz,-cameraTime);
            SetCameraField(CAMERA_FIELD_ZOFFSET,zz,cameraTime);
        }

        void UpdateWC3Camera() {
            SetCameraField(CAMERA_FIELD_TARGET_DISTANCE, 0.0f, cameraTime);
            SetCameraField(CAMERA_FIELD_FIELD_OF_VIEW, fov, cameraTime);
            SetCameraField(CAMERA_FIELD_FARZ, 7000.0f, cameraTime);
            SetCameraField(CAMERA_FIELD_NEARZ, 16.0f, cameraTime);

            Vector2 direction = Vector2(Cos(Deg2Rad(currentFacing.x)), Sin(Deg2Rad(currentFacing.x)));
            float newX = position.x + 100*Cos(Deg2Rad(currentFacing.y))*direction.x;
            float newY = position.y + 100*Cos(Deg2Rad(currentFacing.y))*direction.y;

            //SetCameraPosition(newX, newY);
            PanCameraToTimed(newX, newY, cameraTime);
            SetCameraZ(position.z + eyePosition + 100*Sin(Deg2Rad(currentFacing.y)));
            //SetCameraField(CAMERA_FIELD_ZOFFSET, position.z + 90.0f + Sin(Deg2Rad(currentFacing.y)), 0.0);
            SetCameraField(CAMERA_FIELD_ROTATION, currentFacing.x, cameraTime);
            SetCameraField(CAMERA_FIELD_ANGLE_OF_ATTACK, currentFacing.y, cameraTime);

        }

        void InputMouse() {
            Vector2 mousePos = Vector2(GetMouseScreenRelativeX(), GetMouseScreenRelativeY());

            if(Vector2Distance(mousePos, SCREEN_CENTER) > 0.0000001f) {
                targetFacing.x -= (mousePos.x - SCREEN_CENTER.x) * cameraSpeed;
                targetFacing.y += (mousePos.y - SCREEN_CENTER.y) * cameraSpeed;
                if(targetFacing.x > 360.0f) { 
                    targetFacing.x -= 360.0f;
                    currentFacing.x = targetFacing.x;
                    //SetCameraField(CAMERA_FIELD_ROTATION, currentFacing.x, 0);
                }
                if(targetFacing.x < 0.0f) {
                    targetFacing.x += 360.0f;
                    currentFacing.x = targetFacing.x;
                    //SetCameraField(CAMERA_FIELD_ROTATION, currentFacing.x, 0);
                }
                if(targetFacing.y > 89.0f) targetFacing.y = 89.0f;
                if(targetFacing.y < -89.0f) targetFacing.y = -89.0f;


                SetMouseScreenRelativePosition(SCREEN_CENTER.x, SCREEN_CENTER.y);
            }

            if(blockBreakCooldown > 0) blockBreakCooldown--;
            if(IsMouseKeyPressed(MOUSE_BUTTON_TYPE_LEFT) && blockBreakCooldown == 0) {
                Collision::BlockRaycastInfo hit = Collision::BlockRaycastInfo();
                if(Collision::RaycastBlock(  @world, 
                                            Vector3(absolute_position.x, absolute_position.y, absolute_position.z + PLAYER_DEFAULT_EYES_POSITION),
                                            GetCameraForward(),
                                            BLOCK_SIZE * 5,
                                            hit)) {
                    World::Chunk@ chunk = @hit.position.chunk;
                    chunk.SetBlock(World::BlockPos(@chunk,
                                            hit.position.x,// - chunk.position.x * CHUNK_SIZE, 
                                            hit.position.y,// - chunk.position.y * CHUNK_SIZE, 
                                            hit.position.z), World::BlockID::AIR);// - chunk.position.z * CHUNK_SIZE), World::BlockID::AIR);
                    blockBreakCooldown = 10;
                }
            }
            if(IsKeyPressed(OSKEY_E) && blockBreakCooldown == 0) {
                Collision::BlockRaycastInfo hit = Collision::BlockRaycastInfo();
                if(Collision::RaycastBlock(  @world, 
                                            Vector3(absolute_position.x, absolute_position.y, absolute_position.z + PLAYER_DEFAULT_EYES_POSITION),
                                            GetCameraForward(),
                                            BLOCK_SIZE * 5,
                                            hit)) {
                    //__debug("pos " + hit.position + " face " + hit.face);
                    Vector3I placementPosition = Vector3I(  hit.position.chunk.position.x*CHUNK_SIZE + hit.position.x, 
                                                            hit.position.chunk.position.y*CHUNK_SIZE + hit.position.y, 
                                                            hit.position.chunk.position.z*CHUNK_SIZE + hit.position.z) + hit.face;
                    World::BlockPos bpos = world.GetBlockByAbsoluteBlockPos(World::BlockPos(placementPosition.x, placementPosition.y, placementPosition.z));
                    bpos.chunk.SetBlock(bpos, World::BlockID::GRASS);// - chunk.position.z * CHUNK_SIZE), World::BlockID::GRASS);
                    blockBreakCooldown = 10;
                }
            }
        }

        void InputKeyboard() {
            float x = 0.0f, y = 0.0f;
            if(IsKeyPressed(OSKEY_W)) y += 1.0f;
            if(IsKeyPressed(OSKEY_S)) y -= 1.0f;
            if(IsKeyPressed(OSKEY_D)) x += 1.0f;
            if(IsKeyPressed(OSKEY_A)) x -= 1.0f;

            if(x == 0.0f && y == 0.0f) {
                isSprinting = false;
            }

            Vector3 fwd = GetCameraForward();
            Vector3 right = GetCameraRight();
            fwd.z = 0; right.z = 0;

            Vector3 movement = (fwd * y + right * x).Normalized();
            movement *= speed;

            if(IsKeyPressed(OSKEY_SPACE) && onGround) {
                movement.z = PLAYER_JUMP_STRENGTH;
            }
            if(IsKeyPressed(OSKEY_SHIFT)) {
                isSneaking = true;
                isSprinting = false;
            } else {
                isSneaking = false;
            }

            if(IsKeyPressed(OSKEY_CONTROL)) {
                isSprinting = true;
                isSneaking = false;
            }

            speed = (isSneaking) ? (PLAYER_SNEAKING_SPEED) : (isSprinting ? PLAYER_SPRINTING_SPEED : PLAYER_DEFAULT_SPEED);
            fov = isSprinting ? PLAYER_SPRINTING_FOV : PLAYER_DEFAULT_FOV;
            eyePosition = isSneaking ? PLAYER_SNEAKING_EYES_POSITION : PLAYER_DEFAULT_EYES_POSITION;

            // if(IsKeyPressed(OSKEY_SPACE)) movement.z = 1.0f * speed;
            // if(IsKeyPressed(OSKEY_SHIFT)) movement.z = -1.0f * speed;
            
            motion += movement;
            //SetPosition(absolute_position + movement);
        }
    
        void Update() {
            if(IsWindowActive()) {
                InputMouse();
                if(!waitingForChunksToLoad) {
                    InputKeyboard();
                }
            }
            if(!waitingForChunksToLoad) {
                if(motion.z > -32.0f) {
                    motion.z -= GRAVITY * 1.0f/60.0f;
                }
            }
            UpdateMovement();

            currentFacing.x = expDecay(currentFacing.x, targetFacing.x, facingSmoothFactor, 1./60);
            currentFacing.y = expDecay(currentFacing.y, targetFacing.y, facingSmoothFactor, 1./60);

            UpdateWC3Camera();

            World::ChunkPos newPos = World::AbsolutePositionToChunkPos(absolute_position);
            if(newPos != _currentChunk) {
                //BenchmarkReset();
                //BenchmarkStart();
                _currentChunk = newPos;
                world.UpdateBuiltChunks(World::AbsolutePositionToChunkPos(position), newPos);
                //BenchmarkEnd();
                //print("UpdateBuiltChunks took " + BenchmarkGetElapsed(2) + " ms.\n");
                // print("New position (" + newPos + ") is not equal to old (" + _currentChunk + ")\n");
                // if(world.IsBorderChunk(newPos)) print("Is Border Chunk!\n");
                // world.UnloadChunk(_currentChunk);
                // world.RequestChunk(_currentChunk);
            }
        }

        // tries to move colliding with world
        void Move(Vector3 move) {
            Vector3 movement;

            Vector3 pmin = Vector3(absolute_position.x - PLAYER_SIZE / 2, absolute_position.y - PLAYER_SIZE / 2, absolute_position.z - PLAYER_HEIGHT / 2);
            Vector3 pmax = Vector3(absolute_position.x + PLAYER_SIZE / 2, absolute_position.y + PLAYER_SIZE / 2, absolute_position.z + PLAYER_HEIGHT / 2);
            Collision::AABB paabb = Collision::AABB(pmin, pmax);

            if(isSneaking && onGround) {
                while(move.x != 0.0f) {
                    float movex = (move.x >= 0.0f) ? (PLAYER_BLOCK_SNAP_QUALITY/2) : (-PLAYER_BLOCK_SNAP_QUALITY);
                    array<Collision::AABB> c = world.GetAABBCollisionBoxes(paabb.offset(move.x + movex, 0.0f, -stepHeight));
                    // __debug("clen " + c.length());
                    // for(int i = 0; i < c.length(); i++) {
                    //     __debug("aabb " + c[i]);
                    // }
                    if(c.length() != 0) break;

                    if(move.x < PLAYER_BLOCK_SNAP_QUALITY && move.x >= -PLAYER_BLOCK_SNAP_QUALITY) move.x = 0.0f;
                    else if(move.x > 0.0f) move.x -= PLAYER_BLOCK_SNAP_QUALITY;
                    else move.x += PLAYER_BLOCK_SNAP_QUALITY;
                    //__debug("move.x " + move.x + " clen " + c.length());
                }
                while(move.y != 0.0f) {
                    float movey = (move.y >= 0.0f) ? (PLAYER_BLOCK_SNAP_QUALITY/2) : (-PLAYER_BLOCK_SNAP_QUALITY);
                    array<Collision::AABB> c = world.GetAABBCollisionBoxes(paabb.offset(0.0f, move.y + movey, -stepHeight));
                    if(c.length() != 0) break;

                    if(move.y < PLAYER_BLOCK_SNAP_QUALITY && move.y >= -PLAYER_BLOCK_SNAP_QUALITY) move.y = 0.0f;
                    else if(move.y > 0.0f) move.y -= PLAYER_BLOCK_SNAP_QUALITY;
                    else move.y += PLAYER_BLOCK_SNAP_QUALITY;
                    //__debug("move.y " + move.y + " clen " + c.length());
                }
                while(move.x != 0.0f && move.y != 0.0f) {
                    float movex = (move.x >= 0.0f) ? (PLAYER_BLOCK_SNAP_QUALITY/2) : (-PLAYER_BLOCK_SNAP_QUALITY);
                    float movey = (move.y >= 0.0f) ? (PLAYER_BLOCK_SNAP_QUALITY/2) : (-PLAYER_BLOCK_SNAP_QUALITY);
                    array<Collision::AABB> c = world.GetAABBCollisionBoxes(paabb.offset(move.x + movex, move.y + movey, -stepHeight));
                    if(c.length() != 0) break;

                    if(move.x < PLAYER_BLOCK_SNAP_QUALITY && move.x >= -PLAYER_BLOCK_SNAP_QUALITY) move.x = 0.0f;
                    else if(move.x > 0.0f) move.x -= PLAYER_BLOCK_SNAP_QUALITY;
                    else move.x += PLAYER_BLOCK_SNAP_QUALITY;

                    if(move.y < PLAYER_BLOCK_SNAP_QUALITY && move.y >= -PLAYER_BLOCK_SNAP_QUALITY) move.y = 0.0f;
                    else if(move.y > 0.0f) move.y -= PLAYER_BLOCK_SNAP_QUALITY;
                    else move.y += PLAYER_BLOCK_SNAP_QUALITY;
                    //__debug("move.x " + move.x + "move.y " + move.y + " clen " + c.length());
                }
            } //else __debug("inair");

            Collision::AABB expanded = paabb.expand(move.x, move.y, move.z);
            array<Collision::AABB> collisions = world.GetAABBCollisionBoxes(expanded);
            if(!world.lastAABBCollisionBoxesGetWasSuccessful) {
                waitingForChunksToLoad = true;
                return;
            } else waitingForChunksToLoad = false;

            Vector3 oldMove = move;


            if(!IsZero(move.y)) {
                float r = move.y;
                for(int i = 0; i < collisions.length(); i++) {
                    move.y = collisions[i].calculateYOffset(paabb, move.y);
                }

                paabb = paabb.offset(0.0f, move.y, 0.0f);
            }
            if(!IsZero(move.x)) {
                for(int i = 0; i < collisions.length(); i++) {
                    move.x = collisions[i].calculateXOffset(paabb, move.x);
                }
                if(!IsZero(move.x)) {
                    paabb = paabb.offset(move.x, 0.0f, 0.0f);
                }
            }
            if(!IsZero(move.z)) {
                for(int i = 0; i < collisions.length(); i++) {
                    move.z = collisions[i].calculateZOffset(paabb, move.z);
                }
                if(!IsZero(move.z)) {
                    paabb = paabb.offset(0.0f, 0.0f, move.z);
                }
            }

            absolute_position = Vector3(paabb.minX + PLAYER_SIZE / 2.0f, paabb.minY + PLAYER_SIZE / 2.0f, paabb.minZ + PLAYER_HEIGHT / 2.0f);
            isCollidedHorizontally = move.x != oldMove.x || move.y != oldMove.y;
            isCollidedVertically = move.z != oldMove.z;
            isCollided = isCollidedHorizontally || isCollidedVertically;
            onGround = isCollidedVertically && move.z < EPSILON;

            if(move.x != oldMove.x) motion.x = 0.0f;
            if(move.y != oldMove.y) motion.y = 0.0f;
            if(move.z != oldMove.z) motion.z = 0.0f;
        }
    }
}
