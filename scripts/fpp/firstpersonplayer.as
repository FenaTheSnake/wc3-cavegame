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

        double stepHeight = PLAYER_STEPHEIGHT;
        bool isSneaking;
        bool isSprinting;

        bool isFlying;
        float doubleJumpCooldown = 0;

        bool onGround;
        bool isCollidedHorizontally;
        bool isCollidedVertically;
        bool isCollided;

        bool waitingForChunksToLoad;    // movement is disabled while potentional collidable chunks are loading

        float eyePosition = PLAYER_DEFAULT_EYES_POSITION;
        float fov = PLAYER_DEFAULT_FOV;
        Vector2 targetFacing;
        Vector2 currentFacing;
        float facingSmoothFactor = 24.0f;

        float cameraTime = 0.02f;

        float speed = 4.0f;
        float cameraSpeed = 100.0f;
        int blockBreakCooldown = 0;

        int debugKeysCooldown = 10;

        // pos of block looking at.
        Vector3I lookingAt;
        World::BlockID lookingAtBlockID;

        int ignoreMouseFor = 0;

        private World::ChunkPos _currentChunk;


        void Init(World::WorldInstance@ world, const Vector3 &in position) {
            this.absolute_position = position;
            @this.world = @world;

            currentFacing = Vector2(0.0f, 0.0f);
            targetFacing = Vector2(0.0f, 0.0f);

            //_currentChunk = World::AbsolutePositionToChunkPos(absolute_position);
            //world.RequestChunk(_currentChunk);
        }

        void SetPosition(const Vector3 &in newPosition) {
            Vector3 old_abs = absolute_position;
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

            double d = Vector3Distance(oldPos, position);
            double absd = Vector3Distance(old_abs, absolute_position);
            if(d > 1000.0) {
                SetCameraPosition(position.x, position.y);
                SetCameraField(CAMERA_FIELD_ZOFFSET, position.z, 0.0);
            }
            if(absd > 3000.0) {
                world.UnloadChunksGraphicsBasedOnAbsolutePosition(World::AbsolutePositionToChunkPos(absolute_position));
                world.UpdateBuiltChunksPositions();
            }
        }

        void UpdateMovement() {
            Move(motion);
            if(waitingForChunksToLoad) return;

            motion.x = motion.x * 0.85;
            motion.y = motion.y * 0.85;
            if(isFlying) motion.z = motion.z * 0.85f;

            Vector3 oldPos = position;
            position = World::AbsolutePositionToWC3Position(absolute_position, false);

            double d = Vector3Distance(oldPos, position);
            if(d > 500.0) {
                SetCameraPosition(position.x, position.y);
                SetCameraField(CAMERA_FIELD_ZOFFSET, position.z, 0.0);
            }
            if(d > 2000.0) {
                world.UpdateBuiltChunksPositions();
                //world.repositionBuiltChunksWhenYouAreReadyPleaseNoPressureJustDoItButPreferablyDoItSoonerOk = true;
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
            SetCameraField(CAMERA_FIELD_FARZ, GetFPS()*(7000.0f/60.0f), cameraTime);
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
                if(ignoreMouseFor == 0) {        
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
                    if(targetFacing.y > 89.9f) targetFacing.y = 89.9f;
                    if(targetFacing.y < -89.9f) targetFacing.y = -89.9f;
                }
                SetMouseScreenRelativePosition(SCREEN_CENTER.x, SCREEN_CENTER.y);
                if(ignoreMouseFor > 0) ignoreMouseFor--;
            }

            if(blockBreakCooldown > 0) blockBreakCooldown--;
            if(IsMouseKeyPressed(MOUSE_BUTTON_TYPE_LEFT) && blockBreakCooldown == 0) {
                Collision::BlockRaycastInfo hit = Collision::BlockRaycastInfo();
                if(Collision::RaycastBlock(  @world, 
                                            Vector3(absolute_position.x, absolute_position.y, absolute_position.z + eyePosition),
                                            GetCameraForward(),
                                            8,
                                            hit)) {
                    World::Chunk@ chunk = @hit.position.chunk;
                    World::BlockPos p = World::BlockPos(@chunk, hit.position.x, hit.position.y, hit.position.z);
                    chunk.SetBlock(p, World::BlockID::AIR, World::SetBlockReason::PLAYER);
                    Multiplayer::SendSetBlock(p, World::BlockID::AIR);
                    
                }
                blockBreakCooldown = 10;
            }
            if(IsMouseKeyPressed(MOUSE_BUTTON_TYPE_MIDDLE) && blockBreakCooldown == 0) {
                Collision::BlockRaycastInfo hit = Collision::BlockRaycastInfo();
                if(Collision::RaycastBlock(  @world, 
                                            Vector3(absolute_position.x, absolute_position.y, absolute_position.z + eyePosition),
                                            GetCameraForward(),
                                            8,
                                            hit)) {
                    //__debug("pos " + hit.position + " face " + hit.face);
                    Vector3I placementPosition = Vector3I(  hit.position.chunk.position.x*CHUNK_SIZE + hit.position.x, 
                                                            hit.position.chunk.position.y*CHUNK_SIZE + hit.position.y, 
                                                            hit.position.chunk.position.z*CHUNK_SIZE + hit.position.z) + hit.face;
                    World::BlockPos bpos = world.GetBlockByAbsoluteBlockPos(World::BlockPos(placementPosition.x, placementPosition.y, placementPosition.z));
                    bpos.chunk.SetBlock(bpos, GUI::Hotbar::GetSelectedBlock(), World::SetBlockReason::PLAYER);
                    Multiplayer::SendSetBlock(bpos, GUI::Hotbar::GetSelectedBlock());
                    
                }
                blockBreakCooldown = 10;
            }
        }

        void InputKeyboard() {
            float x = 0.0f, y = 0.0f;
            if(IsKeyPressed(OSKEY_W)) y += 1.0f;
            if(IsKeyPressed(OSKEY_S)) y -= 1.0f;
            if(IsKeyPressed(OSKEY_D)) x += 1.0f;
            if(IsKeyPressed(OSKEY_A)) x -= 1.0f;


            Vector3 fwd = GetCameraForward();
            Vector3 right = GetCameraRight();
            //fwd.z = 0; right.z = 0;

            Vector3 movement = (fwd * y + right * x);
            movement = Vector3(movement.x * 100, movement.y * 100, 0).Normalized() * speed;

            if(doubleJumpCooldown > 0.0) doubleJumpCooldown -= TIME_PLAYER_UPDATE;
            if(IsKeyPressed(OSKEY_SPACE)) {
                doubleJumpCooldown -= 0.05f; // if we hold space then we don't want to enable/disable flying mode
                if(onGround) {
                    movement.z = PLAYER_JUMP_STRENGTH;
                    movement.x *= 10.0f;
                    movement.y *= 10.0f;
                }
                if(isFlying) {
                    motion.z += PLAYER_DEFAULT_SPEED * 1.5f;
                }
            }
            if(IsKeyPressed(OSKEY_SHIFT)) {
                if(isFlying) {
                    motion.z -= PLAYER_DEFAULT_SPEED * 1.5f;
                }

                isSneaking = true;
                isSprinting = false;
            } else {
                isSneaking = false;
            }

            if(IsKeyPressed(OSKEY_CONTROL)) {
                isSprinting = true;
                isSneaking = false;
            }

            if(y < 1.0f) {
                isSprinting = false;
            }

            speed = (isSneaking) ? (PLAYER_SNEAKING_SPEED) : (isSprinting ? PLAYER_SPRINTING_SPEED : PLAYER_DEFAULT_SPEED);
            fov = isSprinting ? PLAYER_SPRINTING_FOV : PLAYER_DEFAULT_FOV;
            eyePosition = isSneaking ? PLAYER_SNEAKING_EYES_POSITION : PLAYER_DEFAULT_EYES_POSITION;
            
            motion += movement;

            if(debugKeysCooldown > 0) debugKeysCooldown -= 1;
            if(debugKeysCooldown == 0) {
                if(IsKeyPressed(OSKEY_F3)) {
                    if(IsKeyPressed(OSKEY_R)) {
                        world.UpdateBuiltChunksPositions();
                        debugKeysCooldown = 20;
                    }
                    if(IsKeyPressed(OSKEY_S)) {
                        world.Save();
                    }

                    GUI::DebugInfo::Switch();
                    debugKeysCooldown = 20;
                }
            }
        }

        void OnJumpPressed() {
            if(GetTriggerPlayer() != GetLocalPlayer()) return;
            if(doubleJumpCooldown > 0.0) {
                if(!onGround) {
                    isFlying = !isFlying;
                    motion.z = 0;
                    doubleJumpCooldown = 0;
                    return;
                }
            }
            doubleJumpCooldown = DOUBLE_JUMP_DELAY;
        }
    
        void Update() {
            if(IsWindowActive()) {
                if(GUI::cursorHidden) {
                    InputMouse();
                    if(!waitingForChunksToLoad) {
                        InputKeyboard();
                    }
                }
            }
            if(!waitingForChunksToLoad) {
                if(!isFlying && motion.z > PLAYER_MAX_FALLING_SPEED) {
                    motion.z -= GRAVITY * 1.0/60.0;
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
                world.UpdateBuiltChunksPositions();
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
                //__debug("movement " + move + " snap q " + PLAYER_BLOCK_SNAP_QUALITY);
                while(move.x != 0.0) {
                    double movex = (move.x >= 0.0) ? (PLAYER_BLOCK_SNAP_QUALITY/2) : (-PLAYER_BLOCK_SNAP_QUALITY);
                    array<Collision::AABB> c = world.GetAABBCollisionBoxes(paabb.offset(move.x + movex, 0.0, -stepHeight));
                    // __debug("clen " + c.length());
                    // for(int i = 0; i < c.length(); i++) {
                    //     __debug("aabb " + c[i]);
                    // }
                    if(c.length() != 0) break;

                    if(move.x < PLAYER_BLOCK_SNAP_QUALITY && move.x >= -PLAYER_BLOCK_SNAP_QUALITY) move.x = 0.0;
                    else if(move.x > 0.0) move.x -= PLAYER_BLOCK_SNAP_QUALITY;
                    else move.x += PLAYER_BLOCK_SNAP_QUALITY;
                    //__debug("move.x " + move.x + " clen " + c.length());
                }
                while(move.y != 0.0) {
                    double movey = (move.y >= 0.0) ? (PLAYER_BLOCK_SNAP_QUALITY/2) : (-PLAYER_BLOCK_SNAP_QUALITY);
                    array<Collision::AABB> c = world.GetAABBCollisionBoxes(paabb.offset(0.0, move.y + movey, -stepHeight));
                    if(c.length() != 0) break;

                    if(move.y < PLAYER_BLOCK_SNAP_QUALITY && move.y >= -PLAYER_BLOCK_SNAP_QUALITY) move.y = 0.0;
                    else if(move.y > 0.0) move.y -= PLAYER_BLOCK_SNAP_QUALITY;
                    else move.y += PLAYER_BLOCK_SNAP_QUALITY;
                    //__debug("move.y " + move.y + " clen " + c.length());
                }
                while(move.x != 0.0 && move.y != 0.0) {
                    double movex = (move.x >= 0.0) ? (PLAYER_BLOCK_SNAP_QUALITY/2) : (-PLAYER_BLOCK_SNAP_QUALITY);
                    double movey = (move.y >= 0.0) ? (PLAYER_BLOCK_SNAP_QUALITY/2) : (-PLAYER_BLOCK_SNAP_QUALITY);
                    array<Collision::AABB> c = world.GetAABBCollisionBoxes(paabb.offset(move.x + movex, move.y + movey, -stepHeight));
                    if(c.length() != 0) break;

                    if(move.x < PLAYER_BLOCK_SNAP_QUALITY && move.x >= -PLAYER_BLOCK_SNAP_QUALITY) move.x = 0.0;
                    else if(move.x > 0.0) move.x -= PLAYER_BLOCK_SNAP_QUALITY;
                    else move.x += PLAYER_BLOCK_SNAP_QUALITY;

                    if(move.y < PLAYER_BLOCK_SNAP_QUALITY && move.y >= -PLAYER_BLOCK_SNAP_QUALITY) move.y = 0.0;
                    else if(move.y > 0.0) move.y -= PLAYER_BLOCK_SNAP_QUALITY;
                    else move.y += PLAYER_BLOCK_SNAP_QUALITY;
                    //__debug("move.x " + move.x + "move.y " + move.y + " clen " + c.length());
                }
            } //else __debug("inair");

            Collision::AABB expanded = paabb.expand(move.x, move.y, move.z);
            array<Collision::AABB> collisions = world.GetAABBCollisionBoxes(expanded);
            if(!world.lastAABBCollisionBoxesGetWasSuccessful) {
                if(!waitingForChunksToLoad) {
                    waitingForChunksToLoad = true;
                    GUI::Menus::Attention::AddAttention(ATTENTION_LOADING_CHUNKS, ATTENTION_LOADING_CHUNKS_TEXT);
                }
                return;
            } else {
                if(waitingForChunksToLoad) {
                    waitingForChunksToLoad = false;
                    GUI::Menus::Attention::RemoveAttention(ATTENTION_LOADING_CHUNKS);
                }
            }

            Vector3 oldMove = move;


            if(!IsZero(move.y)) {
                double r = move.y;
                for(int i = 0; i < collisions.length(); i++) {
                    move.y = collisions[i].calculateYOffset(paabb, move.y);
                }

                paabb = paabb.offset(0.0, move.y, 0.0);
            }
            if(!IsZero(move.x)) {
                for(int i = 0; i < collisions.length(); i++) {
                    move.x = collisions[i].calculateXOffset(paabb, move.x);
                }
                if(!IsZero(move.x)) {
                    paabb = paabb.offset(move.x, 0.0, 0.0);
                }
            }
            if(!IsZero(move.z)) {
                for(int i = 0; i < collisions.length(); i++) {
                    move.z = collisions[i].calculateZOffset(paabb, move.z);
                }
                if(!IsZero(move.z)) {
                    paabb = paabb.offset(0.0, 0.0, move.z);
                }
            }

            absolute_position = Vector3(paabb.minX + PLAYER_SIZE / 2.0, paabb.minY + PLAYER_SIZE / 2.0, paabb.minZ + PLAYER_HEIGHT / 2.0);
            isCollidedHorizontally = move.x != oldMove.x || move.y != oldMove.y;
            isCollidedVertically = move.z != oldMove.z;
            isCollided = isCollidedHorizontally || isCollidedVertically;
            onGround = isCollidedVertically && move.z < EPSILON;

            if(move.x != oldMove.x) motion.x = 0.0;
            if(move.y != oldMove.y) motion.y = 0.0;
            if(move.z != oldMove.z) motion.z = 0.0;
        }

        void UpdateBlockSelection() {
            Collision::BlockRaycastInfo hit = Collision::BlockRaycastInfo();
            if(Collision::RaycastBlock(  @world, 
                                        Vector3(absolute_position.x, absolute_position.y, absolute_position.z + eyePosition),
                                        GetCameraForward(),
                                        8,
                                        hit)) {
                GUI::SetBlockSelectionPosition(hit.position, hit.face);
                lookingAt = Vector3I(hit.position.x + hit.position.chunk.position.x*CHUNK_SIZE, hit.position.y + hit.position.chunk.position.y*CHUNK_SIZE, hit.position.z + hit.position.chunk.position.z*CHUNK_SIZE);
                lookingAtBlockID = hit.position.chunk.blocks[hit.position.x][hit.position.y][hit.position.z];
                
            } else {
                GUI::HideBlockSelection();
            }
        }

        void IgnoreMouseFor(int ticks) {
            ignoreMouseFor = ticks;
        }
    }
}
