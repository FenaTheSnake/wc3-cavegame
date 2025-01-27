#include "block.as"
#include "chunk.as"
#include "chunkbuilder.as"
#include "worldgenerator.as"
#include "..\\multiplayer\\multiplayer.as"

namespace World {
    class WorldInstance {
        dictionary loadedChunks;    // contains [ChunkPos: Chunk@]

        array<Chunk@> builtChunks;
        array<Chunk@> requestedToBuildChunks;   // chunks that should be built

        Save::WorldSave@ worldSave;

        // Loads given chunk if it is not loaded.
        Chunk@ RequestChunk(const ChunkPos &in position) {
            if(loadedChunks.exists(position)) {
                return null;
            }

            //if(Multiplayer::isHost) {
                Chunk@ c = @worldSave.LoadChunk(position, @this);
                if(c == null) @c = @Generator::GenerateChunk(position, @this);

                loadedChunks[position] = @c;

                return @c;
            // } else {
            //     Chunk@ c = Multiplayer::RequestChunk(position);

            //     loadedChunks[position] = @c;
            // }
        }

        void RequestAndBuildChunk(const ChunkPos &in position) {
            RequestChunk(position);

            //if(Multiplayer::isHost) {
                Chunk@ c = cast<Chunk@>(loadedChunks[position]);
                requestedToBuildChunks.insertLast(@c);
            //}
        }

        // unloads chunk's graphics, and, if neccessary, unloads chunk completely
        bool UnloadChunk(const ChunkPos &in position) {
            if(!loadedChunks.exists(position)) {
                __debug("(UnloadChunk) Chunk can't be unloaded as it is not loaded: " + position);
                return false;
            }
            Chunk@ chunk = cast<Chunk@>(loadedChunks[position]);
            if(chunk.generationState >= ChunkGenerationState::GENERATED) {
                chunk.UnloadGraphics();
                chunk.generationState = ChunkGenerationState::GENERATED;

                int c = builtChunks.findByRef(cast<Chunk@>(loadedChunks[position]));
                if(c < 0) {
                    return false;
                }

                builtChunks.removeAt(c);
                return true;
            } else {
                chunk.generationState = ChunkGenerationState::UNLOADED;
                loadedChunks.delete(position);
                return true;
            }
        }
        bool UnloadChunkCompletely(const ChunkPos &in position) {
            if(!loadedChunks.exists(position)) {
                __debug("(UnloadChunkCompletely) Chunk can't be unloaded as it is not loaded: " + position);
                return false;
            }
            Chunk@ chunk = cast<Chunk@>(loadedChunks[position]);
            if(chunk.generationState >= ChunkGenerationState::GENERATED) {
                chunk.UnloadGraphics();
                chunk.generationState = ChunkGenerationState::UNLOADED;

                int c = builtChunks.findByRef(cast<Chunk@>(loadedChunks[position]));
                loadedChunks[position] = null;
                loadedChunks.delete(position);

                Memory::chunkPool.FreeChunk(chunk);
                if(c < 0) {
                    //__debug("chunk is loaded but not built!");
                    //__debug_section_end();
                    return false;
                }

                builtChunks.removeAt(c);
                //__debug("unloaded successfully!");
                //__debug_section_end();
                return true;
            } else {
                chunk.generationState = ChunkGenerationState::UNLOADED;
                loadedChunks.delete(position);
                return true;
            }
        }

        // unloads chunks and builds new according to provided position
        // localCenter should be provided as position in wc3's coordinates (bound to map limits)
        // so you can sure that all chunks that are not visible by player have graphics unloaded.
        void UpdateBuiltChunks(const ChunkPos &in localCenter, const ChunkPos &in center) {
            //int visibleChunksCount = Pow((1 + (Main::renderDistance - 1) * 2), 3);
            //array<Chunk@> visibleChunks(visibleChunksCount);

            //__debug_section_start("UpdateBuiltChunks");
            int _debug_unloaded = 0;
            int _debug_loaded = 0;

            for(uint i = 0; i < builtChunks.length(); i++) {
                if(!(builtChunks[i].on_map_position.x > localCenter.x - Main::renderDistance && builtChunks[i].on_map_position.x < localCenter.x + Main::renderDistance &&
                     builtChunks[i].on_map_position.y > localCenter.y - Main::renderDistance && builtChunks[i].on_map_position.y < localCenter.y + Main::renderDistance &&
                     builtChunks[i].position.z > center.z - Main::renderDistance_z && builtChunks[i].position.z < center.z + Main::renderDistance_z)) {
                    //__debug("unload chunk");
                    if(UnloadChunk(builtChunks[i].position)) {
                        _debug_unloaded ++;
                        i--;
                    }
                }
            }

            for(uint i = 0; i < requestedToBuildChunks.length(); i++) {
                if(!(requestedToBuildChunks[i].on_map_position.x > localCenter.x - Main::renderDistance && requestedToBuildChunks[i].on_map_position.x < localCenter.x + Main::renderDistance &&
                     requestedToBuildChunks[i].on_map_position.y > localCenter.y - Main::renderDistance && requestedToBuildChunks[i].on_map_position.y < localCenter.y + Main::renderDistance &&
                     requestedToBuildChunks[i].position.z > center.z - Main::renderDistance_z && requestedToBuildChunks[i].position.z < center.z + Main::renderDistance_z)) {
                    //requestedToBuildChunks[i].generationState = ChunkGenerationState::GENERATED;
                    requestedToBuildChunks.removeAt(i);
                    i--;
                }
            }

            for(uint i = 0; i < Builder::chunksBeingBuilt.length(); i++) {
                if(!(Builder::chunksBeingBuilt[i].chunk.on_map_position.x > localCenter.x - Main::renderDistance && Builder::chunksBeingBuilt[i].chunk.on_map_position.x < localCenter.x + Main::renderDistance &&
                     Builder::chunksBeingBuilt[i].chunk.on_map_position.y > localCenter.y - Main::renderDistance && Builder::chunksBeingBuilt[i].chunk.on_map_position.y < localCenter.y + Main::renderDistance &&
                     Builder::chunksBeingBuilt[i].chunk.position.z > center.z - Main::renderDistance_z && Builder::chunksBeingBuilt[i].chunk.position.z < center.z + Main::renderDistance_z)) {
                    Builder::chunksBeingBuilt[i].chunk.UnloadGraphics();
                    Builder::chunksBeingBuilt[i].chunk.generationState = ChunkGenerationState::GENERATED;
                    Builder::chunksBeingBuilt.removeAt(i);
                    i--;
                }
            }

            for(int i = center.x - (Main::renderDistance - 1); i <= center.x + (Main::renderDistance - 1); i++) {
                for(int j = center.y - (Main::renderDistance - 1); j <= center.y + (Main::renderDistance - 1); j++) {
                    for(int k = center.z - (Main::renderDistance_z - 1); k <= center.z + (Main::renderDistance_z - 1); k++) {
                        //__debug("request and build");
                        RequestAndBuildChunk(ChunkPos(i, j, k));
                        _debug_loaded ++;
                    }
                }
            }

            //__debug("Requested / Unloaded chunks: " + _debug_loaded + " / " + _debug_unloaded);
            //__debug("ReservedGraphics usage: " + Memory::usedGraphics.length() + "/" + RESERVE_GRAPHICS_COUNT);
            //__debug("ChunkPool usage: " + Memory::chunkPool.usedChunks.length() + "/" + CHUNK_POOL_MAX_SIZE);
            //__debug_section_end();
        }

        void ProcessRequestedToBuildChunks() {
            for(uint i = 0; i < requestedToBuildChunks.length(); i++) {
                Chunk@ c = @requestedToBuildChunks[i];
                if(c.generationState == ChunkGenerationState::GENERATED) {
                    Builder::BuildChunk(@c);
                    requestedToBuildChunks.removeAt(i);
                    i--; continue;
                }
                if(c.generationState != ChunkGenerationState::GENERATING) {
                    requestedToBuildChunks.removeAt(i);
                    i--; continue;
                }
            }
        }

        // unloads all chunks that are generated but not built
        void UnloadUnrelevantChunksIfNecessary() {
            if(Memory::chunkPool.IsRequiresClearing()) {
                Save();
            }
        }

        // true = block is not visible
        bool IsBlockOccluded(ChunkPos &in pos, int blockX, int blockY, int blockZ) {
            uint occludedSides = 0;
            if(!loadedChunks.exists(pos)) {
                return true;
            }
            Chunk@ c = cast<Chunk@>(loadedChunks[pos]);

            if(blockX - 1 == -1) {
                ChunkPos posL = ChunkPos(pos.x - 1, pos.y, pos.z);
                if(loadedChunks.exists(posL)) {
                    Chunk@ cl = cast<Chunk@>(loadedChunks[posL]);
                    if(cl.blocks[CHUNK_SIZE - 1][blockY][blockZ] != BlockID::AIR) occludedSides++;
                } else occludedSides++;
            } else {
                if(c.blocks[blockX-1][blockY][blockZ] != BlockID::AIR) occludedSides++;
            }
            if(blockX + 1 == CHUNK_SIZE) {
                ChunkPos posR = ChunkPos(pos.x + 1, pos.y, pos.z);
                if(loadedChunks.exists(posR)) {
                    Chunk@ cr = cast<Chunk@>(loadedChunks[posR]);
                    if(cr.blocks[0][blockY][blockZ] != BlockID::AIR) occludedSides++;
                } else occludedSides++;
            } else {
                if(c.blocks[blockX+1][blockY][blockZ] != BlockID::AIR) occludedSides++;
            }

            if(blockY - 1 == -1) {
                ChunkPos posB = ChunkPos(pos.x, pos.y - 1, pos.z);
                if(loadedChunks.exists(posB)) {
                    Chunk@ cb = cast<Chunk@>(loadedChunks[posB]);
                    if(cb.blocks[blockX][CHUNK_SIZE - 1][blockZ] != BlockID::AIR) occludedSides++;
                } else occludedSides++;
            } else {
                if(c.blocks[blockX][blockY-1][blockZ] != BlockID::AIR) occludedSides++;
            }
            if(blockY + 1 == CHUNK_SIZE) {
                ChunkPos posF = ChunkPos(pos.x, pos.y + 1, pos.z);
                if(loadedChunks.exists(posF)) {
                    Chunk@ cf = cast<Chunk@>(loadedChunks[posF]);
                    if(cf.blocks[blockX][0][blockZ] != BlockID::AIR) occludedSides++;
                } else occludedSides++;
            } else {
                if(c.blocks[blockX][blockY+1][blockZ] != BlockID::AIR) occludedSides++;
            }

            if(blockZ - 1 == -1) {
                ChunkPos posD = ChunkPos(pos.x, pos.y, pos.z - 1);
                if(loadedChunks.exists(posD)) {
                    Chunk@ cd = cast<Chunk@>(loadedChunks[posD]);
                    if(cd.blocks[blockX][blockY][CHUNK_SIZE - 1] != BlockID::AIR) occludedSides++;
                } else occludedSides++;
            } else {
                if(c.blocks[blockX][blockY][blockZ-1] != BlockID::AIR) occludedSides++;
            }
            if(blockZ + 1 == CHUNK_SIZE) {
                ChunkPos posU = ChunkPos(pos.x, pos.y, pos.z + 1);
                if(loadedChunks.exists(posU)) {
                    Chunk@ cu = cast<Chunk@>(loadedChunks[posU]);
                    if(cu.blocks[blockX][blockY][0] != BlockID::AIR) occludedSides++;
                } else occludedSides++;
            } else {
                if(c.blocks[blockX][blockY][blockZ+1] != BlockID::AIR) occludedSides++;
            }

            //if(occludedSides == 6) {
                //__debug("occluded " + blockX + " " + blockY + " " + blockZ + ", chunkPos " + pos);
            //}
            return occludedSides == 6;
        }

        // returns blockpos, (-1,-1,-1) if chunk is not loaded
        BlockPos GetBlockByAbsolutePosition(Vector3 position) {
            ChunkPos c = AbsolutePositionToChunkPos(position);
            if(loadedChunks.exists(c) && cast<Chunk@>(loadedChunks[c]).generationState >= ChunkGenerationState::GENERATED) {
                Chunk chunk = cast<Chunk@>(loadedChunks[c]);

                BlockPos blockPos = chunk.AbsolutePositionToChunkBlockPos(position);
                return blockPos;
            }
            return BlockPos();
        }
        Chunk@ GetChunkByBlockPos(BlockPos blockPos) {
            if(blockPos.chunk != null) return @blockPos.chunk;
            ChunkPos c = ChunkPos(MathRealFloor(1.0f*blockPos.x / CHUNK_SIZE), MathRealFloor(1.0f*blockPos.y / CHUNK_SIZE), MathRealFloor(1.0f*blockPos.z / CHUNK_SIZE));
            if(loadedChunks.exists(c) && cast<Chunk@>(loadedChunks[c]).generationState >= ChunkGenerationState::GENERATED) {
                Chunk@ chunk = cast<Chunk@>(loadedChunks[c]);
                return chunk;
            }
            return null;
        }
        ChunkPos GetChunkPosByBlockPos(BlockPos blockPos) {
            if(blockPos.chunk != null) return blockPos.chunk.position;
            ChunkPos c = ChunkPos(MathRealFloor(1.0f*blockPos.x / CHUNK_SIZE), MathRealFloor(1.0f*blockPos.y / CHUNK_SIZE), MathRealFloor(1.0f*blockPos.z / CHUNK_SIZE));
            return c;
        }

        // finds what chunk this blockPos related to and returns local blockPos
        // ex. (9, 0, 0) -> (2, 0, 0)/chunk(1,0,0)
        BlockPos GetBlockByAbsoluteBlockPos(BlockPos blockPos) {
            ChunkPos c = ChunkPos(MathRealFloor(1.0f*blockPos.x / CHUNK_SIZE), MathRealFloor(1.0f*blockPos.y / CHUNK_SIZE), MathRealFloor(1.0f*blockPos.z / CHUNK_SIZE));
            if(loadedChunks.exists(c) && cast<Chunk@>(loadedChunks[c]).generationState >= ChunkGenerationState::GENERATED) {
                Chunk@ chunk = cast<Chunk@>(loadedChunks[c]);

                //__debug("getblock: chunkPos " + c + " blockPos " + blockPos);
                BlockPos p = BlockPos(@chunk, blockPos.x - c.x*CHUNK_SIZE, blockPos.y - c.y*CHUNK_SIZE, blockPos.z - c.z*CHUNK_SIZE);
                //__debug("abspos to localpos: " + blockPos + " -> " + p);
                return p;
            }
            return BlockPos();
        }

        bool lastAABBChunksGetWasSuccessful = false; // if false then some of the chunks was unloaded when we tried to get AABB chunks
        // get all chunks that AABB is intersects with
        array<Chunk@> GetAABBChunks(Collision::AABB &in aabb) {
            array<Chunk@> chunks;
            lastAABBChunksGetWasSuccessful = true;

            ChunkPos lbd = AbsolutePositionToChunkPos(Vector3(aabb.minX, aabb.minY, aabb.minZ));
            ChunkPos rfu = AbsolutePositionToChunkPos(Vector3(aabb.maxX, aabb.maxY, aabb.maxZ));

            for(int i = lbd.x; i <= rfu.x; i++) {
                for(int j = lbd.y; j <= rfu.y; j++) {
                    for(int k = lbd.z; k <= rfu.z; k++) {
                        ChunkPos c = ChunkPos(i, j, k);
                        if(loadedChunks.exists(c) && cast<Chunk@>(loadedChunks[c]).generationState >= ChunkGenerationState::BUILT) {
                            chunks.insertLast(cast<Chunk@>(loadedChunks[c]));
                        } else lastAABBChunksGetWasSuccessful = false;
                    }
                }
            }

            return chunks;
        }

        bool lastAABBCollisionBoxesGetWasSuccessful = false;
        // get aabb of all solid blocks within aabb
        array<Collision::AABB> GetAABBCollisionBoxes(Collision::AABB &in aabb) {
            array<Collision::AABB> boxes;
            lastAABBCollisionBoxesGetWasSuccessful = true;

            array<Chunk@> chunks = GetAABBChunks(aabb);
            if(!lastAABBChunksGetWasSuccessful) lastAABBCollisionBoxesGetWasSuccessful = false;

            for(uint chunk_iter = 0; chunk_iter < chunks.length(); chunk_iter++){
                array<Vector3I>@ blocks = @(chunks[chunk_iter].GetAABBBlocks(aabb));
                // if(chunk_iter == 0) {
                //     __debug("blocks " + blocks.length());
                // }
                for(uint block_iter = 0; block_iter < blocks.length(); block_iter++) {
                    BlockID b = chunks[chunk_iter].blocks[blocks[block_iter].x][blocks[block_iter].y][blocks[block_iter].z];
                    if(b != BlockID::AIR) {
                        // Vector3 block_min = Vector3(blocks[block_iter].x * BLOCK_SIZE + chunks[chunk_iter].position.x - BLOCK_SIZE / 2,
                        //                             blocks[block_iter].y * BLOCK_SIZE + chunks[chunk_iter].position.y - BLOCK_SIZE / 2,
                        //                             blocks[block_iter].z * BLOCK_SIZE + chunks[chunk_iter].position.z - BLOCK_SIZE / 2);
                        // Vector3 block_max = Vector3(blocks[block_iter].x * BLOCK_SIZE + chunks[chunk_iter].position.x + BLOCK_SIZE / 2,
                        //                             blocks[block_iter].y * BLOCK_SIZE + chunks[chunk_iter].position.y + BLOCK_SIZE / 2,
                        //                             blocks[block_iter].z * BLOCK_SIZE + chunks[chunk_iter].position.z + BLOCK_SIZE / 2);
                        Vector3 block_min = Vector3(blocks[block_iter].x * BLOCK_SIZE + chunks[chunk_iter].position.x * CHUNK_SIZE * BLOCK_SIZE,
                                                    blocks[block_iter].y * BLOCK_SIZE + chunks[chunk_iter].position.y * CHUNK_SIZE * BLOCK_SIZE,
                                                    blocks[block_iter].z * BLOCK_SIZE + chunks[chunk_iter].position.z * CHUNK_SIZE * BLOCK_SIZE);
                        Vector3 block_max = Vector3(blocks[block_iter].x * BLOCK_SIZE + chunks[chunk_iter].position.x * CHUNK_SIZE * BLOCK_SIZE + BLOCK_SIZE,
                                                    blocks[block_iter].y * BLOCK_SIZE + chunks[chunk_iter].position.y * CHUNK_SIZE * BLOCK_SIZE + BLOCK_SIZE,
                                                    blocks[block_iter].z * BLOCK_SIZE + chunks[chunk_iter].position.z * CHUNK_SIZE * BLOCK_SIZE + BLOCK_SIZE);
                        
                        //__debug("block " + block_min + " " + block_max);
                        //SetSpecialEffectVertexColour(b.graphics.get().eff, 255, 92, 92, 255);
                        //b.debug = true;
                        boxes.insertLast(Collision::AABB(block_min, block_max));
                    }
                }
            }
            return boxes;
        }

        // updates already built chunks position
        // used when player loops back to reposition already generated chunks and do not generate them again
        void UpdateBuiltChunksPositions() {
            for(uint i = 0; i < builtChunks.length(); i++) {
                ChunkPos prev = builtChunks[i].on_map_position;
                builtChunks[i].on_map_position = World::ChunkPosToWC3Position(builtChunks[i].position);
                if(prev != builtChunks[i].on_map_position) {
                    Builder::RepositionChunk(@builtChunks[i]);
                }
            }

            for(uint i = 0; i < Builder::chunksBeingBuilt.length(); i++) {
                ChunkPos prev = Builder::chunksBeingBuilt[i].chunk.on_map_position;
                Builder::chunksBeingBuilt[i].chunk.on_map_position = World::ChunkPosToWC3Position(Builder::chunksBeingBuilt[i].chunk.position);
                if(prev != Builder::chunksBeingBuilt[i].chunk.on_map_position) {
                    Builder::RepositionChunk(@Builder::chunksBeingBuilt[i].chunk);
                }
            }

            for(uint i = 0; i < requestedToBuildChunks.length(); i++) {
                requestedToBuildChunks[i].on_map_position = World::ChunkPosToWC3Position(requestedToBuildChunks[i].position);
            }
        }

        // saves all loaded chunks and unloads all chunks that are unrelevant (not built and no players are inside)
        void Save() {
            worldSave.BeginSaving();

            array<string>@ keys = loadedChunks.getKeys();
            for(int i = 0; i < keys.length(); i++) {
                Chunk@ c = cast<Chunk@>(loadedChunks[keys[i]]);
                if(c.generationState >= ChunkGenerationState::GENERATED && c.wasModified) {
                    worldSave.AddChunk(@c);
                }
                if(c.generationState == ChunkGenerationState::GENERATED) {
                    UnloadChunkCompletely(c.position);
                }
            }

            worldSave.FinishSaving();
        }
    }

    ChunkPos AbsolutePositionToChunkPos(const Vector3 &in absPosition) {
        ChunkPos pos = ChunkPos(int(MathRealFloor(absPosition.x / (CHUNK_SIZE * BLOCK_SIZE))), int(MathRealFloor(absPosition.y / (CHUNK_SIZE * BLOCK_SIZE))), int(MathRealFloor(absPosition.z / (CHUNK_SIZE * BLOCK_SIZE))));
        return pos;
    }

    // Converts absolute world position to wc3's position (Bound to map limits)
    // The map is looped in n = (MAP_SIZE / CHUNK_SIZE - renderDistance*2) chunks (32 - 8 with default settings)
    // it means you get looped back every n (24) chunks.
    // 'placeOutOfBorder' checks if player is near border so it return coordinates beyond the border
    // to make an illusion of seamless world.
    // commonly should be 'true' for every situation expect for the player itself.
    Vector3 AbsolutePositionToWC3Position(const Vector3 &in position, bool placeOutOfBorder) {
        Vector3 result = Vector3();

        int border_chunks_starts_at = (MAP_SIZE / CHUNK_SIZE / 2) - Main::renderDistance;
        float border_xy = BLOCK_SIZE * CHUNK_SIZE * border_chunks_starts_at * 2;

        int border_chunks_starts_at_z = (MAP_SIZE_Z / CHUNK_SIZE / 2) - 1;
        float border_z = BLOCK_SIZE * CHUNK_SIZE * border_chunks_starts_at_z * 2;

        float cx = (position.x + border_xy / 2);
        if(cx >= 0) {
            result.x = (cx % border_xy) - border_xy / 2;
        } else {
            result.x = (border_xy - (-cx % border_xy)) - border_xy / 2;
        }

        float cy = (position.y + border_xy / 2);
        if(cy >= 0) {
            result.y = (cy % border_xy) - border_xy / 2;
        } else {
            result.y = (border_xy - (-cy % border_xy)) - border_xy / 2;
        }

        float cz = (position.z + border_z / 2);
        if(cz >= 0) {
            result.z = (cz % border_z) - border_z / 2;
        } else {
            result.z = (border_z - (-cz % border_z)) - border_z / 2;
        }

        // if(!placeOutOfBorder) {
        //     if(position.z > 0) {
        //         result.z = position.z % (CHUNK_SIZE * BLOCK_SIZE);
        //     } else {
        //         result.z = (CHUNK_SIZE * BLOCK_SIZE) - (-position.z % (CHUNK_SIZE * BLOCK_SIZE));
        //     }
        // }

        if(placeOutOfBorder) {
            Vector3 playerPos = Main::player.position;
            ChunkPos playerChunkPos = AbsolutePositionToChunkPos(Main::player.absolute_position);

            int near_border_start_at = border_chunks_starts_at - Main::renderDistance;
            float near_border_xy = BLOCK_SIZE * CHUNK_SIZE * near_border_start_at;
            float half_border_xy = border_xy / 2;

            int near_border_start_at_z = border_chunks_starts_at_z - 1;
            float near_border_z = BLOCK_SIZE * CHUNK_SIZE * near_border_start_at_z;
            float half_border_z = border_z / 2;

            //__debug("result " + result + "; playerPos " + playerPos + "; nearBorderStartAt " + near_border_start_at + "; nearBorderXY " + near_border_xy + "; halfborder " + half_border_xy);
            
            if(playerPos.x <= -near_border_xy && result.x <= half_border_xy && result.x >= near_border_xy) {
                result.x = -half_border_xy - (half_border_xy - result.x);
            }
            if(playerPos.x >= near_border_xy && result.x >= -half_border_xy && result.x <= -near_border_xy) {
                result.x = half_border_xy - (-half_border_xy - result.x);
            }
            if(playerPos.y <= -near_border_xy && result.y <= half_border_xy && result.y >= near_border_xy) {
                result.y = -half_border_xy - (half_border_xy - result.y);
            }
            if(playerPos.y >= near_border_xy && result.y >= -half_border_xy && result.y <= -near_border_xy) {
                result.y = half_border_xy - (-half_border_xy - result.y);
            }
            if(playerPos.z <= -near_border_z && result.z <= half_border_z && result.z >= near_border_z) {
                result.z = -half_border_z - (half_border_z - result.z);
            }
            if(playerPos.z >= near_border_z && result.z >= -half_border_z && result.z <= -near_border_z) {
                result.z = half_border_z - (-half_border_z - result.z);
            }

            //result.z = position.z - playerChunkPos.z * CHUNK_SIZE * BLOCK_SIZE;
            //__debug("pos z: " + position.z + " | playerChunkPos z: " + (playerChunkPos.z * CHUNK_SIZE * BLOCK_SIZE) + " | result z: " + result.z);

            //__debug("after: result " + result);
        }

        return result;
    }

    ChunkPos ChunkPosToWC3Position(const ChunkPos &in position) {
        Vector3 v = AbsolutePositionToWC3Position(Vector3(position.x * CHUNK_SIZE * BLOCK_SIZE, position.y * CHUNK_SIZE * BLOCK_SIZE, position.z * CHUNK_SIZE * BLOCK_SIZE), true);
        //__debug("chunkPosToWC3 " + position + " -> " + ChunkPos(int(v.x / BLOCK_SIZE / CHUNK_SIZE), int(v.y / BLOCK_SIZE / CHUNK_SIZE), int(v.z / BLOCK_SIZE / CHUNK_SIZE)));
        return ChunkPos(int(v.x / BLOCK_SIZE / CHUNK_SIZE), int(v.y / BLOCK_SIZE / CHUNK_SIZE), int(v.z / BLOCK_SIZE / CHUNK_SIZE));
    }

    // border chunk is a chunk that placed beyond playable border to imitate seamless infinite world
    // in fact it is a completely normal chunk that just displayed in different place.
    // TODO: make it more effective idk...
    bool IsBorderChunk(const ChunkPos &in position) {
        Vector3 worldPos = Vector3(position.x * CHUNK_SIZE * BLOCK_SIZE, position.y * CHUNK_SIZE * BLOCK_SIZE, position.z * CHUNK_SIZE * BLOCK_SIZE);

        int border_chunks_starts_at = (MAP_SIZE / CHUNK_SIZE / 2) - Main::renderDistance;
        float border_xy = BLOCK_SIZE * CHUNK_SIZE * border_chunks_starts_at * 2;
        float half_border_xy = border_xy / 2;

        int border_chunks_starts_at_z = (MAP_SIZE_Z / CHUNK_SIZE / 2) - 1;
        float border_z = BLOCK_SIZE * CHUNK_SIZE * border_chunks_starts_at_z * 2;
        float half_border_z = border_z / 2;

        return  worldPos.x >= half_border_xy || worldPos.x <= -half_border_xy || 
                worldPos.y >= half_border_xy || worldPos.y <= -half_border_xy ||
                worldPos.z >= half_border_z  || worldPos.z <= -half_border_z;
        

        //return MathIntegerAbs(position.x) >= ((MAP_SIZE / CHUNK_SIZE / 2) - Main::renderDistance) || MathIntegerAbs(position.y) >= ((MAP_SIZE / CHUNK_SIZE / 2) - Main::renderDistance);
    }
}