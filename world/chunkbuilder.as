namespace World {
    namespace Builder {
        class BuildingChunkData {
            Chunk@ chunk;
            uint i, j ,k;    // block that we ended at last time

            BuildingChunkData() {}
            BuildingChunkData(Chunk@ chunk) {
                @this.chunk = @chunk;
                i = 0; j = 0; k = 0;
            }
        }

        array<BuildingChunkData> chunksBeingBuilt;

        int processedBuildingBlocks = 0;
        void ProcessBuildingChunks() {
            processedBuildingBlocks = 0;

            for(uint chunk_iter = 0; chunk_iter < chunksBeingBuilt.length(); chunk_iter++) {
                BuildingChunkData@ data = @chunksBeingBuilt[chunk_iter];
                if(data.chunk.generationState != ChunkGenerationState::BUILDING) {
                    chunksBeingBuilt.removeAt(chunk_iter);
                    chunk_iter--;
                    continue;
                }

                ChunkPos wc3Position = data.chunk.on_map_position;
                //bool isBorder = World::IsBorderChunk(wc3Position);
                //data.chunk._wasBorderChunk = isBorder;

                for(uint i = 0; i < CHUNK_SIZE; i++) {
                    for(uint j = 0; j < CHUNK_SIZE; j++) {
                        for(uint k = 0; k < CHUNK_SIZE; k++) {

                            if(data.i != 0 || data.j != 0 || data.k != 0) {
                                i = data.i; j = data.j; k = data.k;
                                data.i = 0; data.j = 0; data.k = 0;
                            }
                            if(processedBuildingBlocks > Main::toBuildBlocks) {
                                data.i = i; data.j = j; data.k = k;
                                return;
                            }

                            Block@ b = @data.chunk.blocks[i][j][k];
                            if(b.graphics !is null) continue;
                            processedBuildingBlocks++;
        
                            if(b.id == BlockID::GRASS) {
                                if(data.chunk.world.IsBlockOccluded(data.chunk.position, i, j, k)) {
                                    //__debug("builder::occluded " + data.chunk.position.x + i + " " + data.chunk.position.y + j + " " + data.chunk.position.z + k + ", chunkPos " + data.chunk.position);
                                    continue;
                                }

                                @b.graphics = @Memory::GetReservedGraphics();
                                SetSpecialEffectPositionWithZ(b.graphics.get().eff, wc3Position.x * CHUNK_SIZE * BLOCK_SIZE + i * 128, wc3Position.y * CHUNK_SIZE * BLOCK_SIZE + j * 128, wc3Position.z * CHUNK_SIZE * BLOCK_SIZE + k*128);
                                //if(b.debug) SetSpecialEffectVertexColour(b.graphics.get().eff, 255, 92, 92, 255);
                                //else SetSpecialEffectVertexColour(b.graphics.get().eff, 255, 255, 255, 255);
                            }
                        }
                    }
                }

                data.chunk.generationState = ChunkGenerationState::BUILT;
                data.chunk.world.builtChunks.insertLast(@data.chunk);
                chunksBeingBuilt.removeAt(chunk_iter);
                chunk_iter--;

            }
        }

        // Sends chunk to list of chunks to be built later.
        // thus the returned chunk is not shown immediately!
        bool BuildChunk(Chunk@ chunk) {
            if(chunk.generationState != ChunkGenerationState::GENERATED) {
                return false;
            }

            chunk.generationState = ChunkGenerationState::BUILDING;
            chunksBeingBuilt.insertLast(BuildingChunkData(@chunk));

            return true;
        }

        // update chunk's graphics position to new chunk's position
        void RepositionChunk(Chunk@ chunk) {
            ChunkPos wc3Position = chunk.on_map_position;
            for(uint i = 0; i < CHUNK_SIZE; i++) {
                for(uint j = 0; j < CHUNK_SIZE; j++) {
                    for(uint k = 0; k < CHUNK_SIZE; k++) {
                        Block@ b = @chunk.blocks[i][j][k];
                        if(b.graphics is null) continue;
    
                        if(b.id != BlockID::AIR) {
                            if(chunk.world.IsBlockOccluded(chunk.position, i, j, k)) {
                                continue;
                            }

                            SetSpecialEffectPositionWithZ(b.graphics.get().eff, wc3Position.x * CHUNK_SIZE * BLOCK_SIZE + i * 128, wc3Position.y * CHUNK_SIZE * BLOCK_SIZE + j * 128, wc3Position.z * CHUNK_SIZE * BLOCK_SIZE + k*128);
                        }
                    }
                }
            }
        }

        void UpdateChunkBlockGraphics(Chunk@ chunk, Vector3I blockPos, bool updateNeighbors) {
            //__debug("updating graphics " + Vector3(chunk.position.x*CHUNK_SIZE+blockPos.x,chunk.position.y*CHUNK_SIZE+blockPos.y,chunk.position.z*CHUNK_SIZE+blockPos.z));
            Block@ b = @chunk.blocks[blockPos.x][blockPos.y][blockPos.z];
            if(b.id == BlockID::AIR || chunk.world.IsBlockOccluded(chunk.position, blockPos.x, blockPos.y, blockPos.z)) {
                if(b.graphics !is null) {
                    Memory::FreeReservedGraphics(@b.graphics);
                    @b.graphics = null;
                }
            } else {
                if(b.graphics is null && !chunk.world.IsBlockOccluded(chunk.position, blockPos.x, blockPos.y, blockPos.z)) {
                    //__debug("is solid and visible, allocating graphics");
                    ChunkPos wc3Position = chunk.on_map_position;
                    @b.graphics = @Memory::GetReservedGraphics();
                    //if(chunk.position.x*CHUNK_SIZE+blockPos.x == 10 && chunk.position.y*CHUNK_SIZE+blockPos.y == 0 && chunk.position.z*CHUNK_SIZE+blockPos.z == 0) {
                        //@Main::_debugRD = @b.graphics;
                    //}
                    SetSpecialEffectPositionWithZ(b.graphics.get().eff, wc3Position.x * CHUNK_SIZE * BLOCK_SIZE + blockPos.x * 128, 
                                                                        wc3Position.y * CHUNK_SIZE * BLOCK_SIZE + blockPos.y * 128, 
                                                                        wc3Position.z * CHUNK_SIZE * BLOCK_SIZE + blockPos.z * 128);
                }
            }

            if(updateNeighbors) {
                ChunkPos pos = chunk.position;
                //__debug("checking left");
                if(blockPos.x - 1 == -1) {
                    ChunkPos posL = ChunkPos(pos.x - 1, pos.y, pos.z);
                    if(chunk.world.loadedChunks.exists(posL)) {
                        Chunk@ cl = cast<Chunk@>(chunk.world.loadedChunks[posL]);
                        UpdateChunkBlockGraphics(@cl, Vector3I(CHUNK_SIZE - 1, blockPos.y, blockPos.z), false);
                    }
                } else UpdateChunkBlockGraphics(@chunk, Vector3I(blockPos.x - 1, blockPos.y, blockPos.z), false);
                //__debug("checking right");
                if(blockPos.x + 1 == CHUNK_SIZE) {
                    ChunkPos posR = ChunkPos(pos.x + 1, pos.y, pos.z);
                    if(chunk.world.loadedChunks.exists(posR)) {
                        Chunk@ cr = cast<Chunk@>(chunk.world.loadedChunks[posR]);
                        UpdateChunkBlockGraphics(@cr, Vector3I(0, blockPos.y, blockPos.z), false);
                    }
                } else UpdateChunkBlockGraphics(@chunk, Vector3I(blockPos.x + 1, blockPos.y, blockPos.z), false);

                //__debug("checking back");
                if(blockPos.y - 1 == -1) {
                    ChunkPos posB = ChunkPos(pos.x, pos.y - 1, pos.z);
                    if(chunk.world.loadedChunks.exists(posB)) {
                        Chunk@ cb = cast<Chunk@>(chunk.world.loadedChunks[posB]);
                        UpdateChunkBlockGraphics(@cb, Vector3I(blockPos.x, CHUNK_SIZE - 1, blockPos.z), false);
                    }
                } else UpdateChunkBlockGraphics(@chunk, Vector3I(blockPos.x, blockPos.y - 1, blockPos.z), false);
                //__debug("checking front");
                if(blockPos.y + 1 == CHUNK_SIZE) {
                    ChunkPos posF = ChunkPos(pos.x, pos.y + 1, pos.z);
                    if(chunk.world.loadedChunks.exists(posF)) {
                        Chunk@ cf = cast<Chunk@>(chunk.world.loadedChunks[posF]);
                        UpdateChunkBlockGraphics(@cf, Vector3I(blockPos.x, 0, blockPos.z), false);
                    }
                } else UpdateChunkBlockGraphics(@chunk, Vector3I(blockPos.x, blockPos.y + 1, blockPos.z), false);
                //__debug("checking down");
                if(blockPos.z - 1 == -1) {
                    ChunkPos posD = ChunkPos(pos.x, pos.y, pos.z - 1);
                    if(chunk.world.loadedChunks.exists(posD)) {
                        Chunk@ cd = cast<Chunk@>(chunk.world.loadedChunks[posD]);
                        UpdateChunkBlockGraphics(@cd, Vector3I(blockPos.x, blockPos.y, CHUNK_SIZE - 1), false);
                    }
                } else UpdateChunkBlockGraphics(@chunk, Vector3I(blockPos.x, blockPos.y, blockPos.z - 1), false);
                //__debug("checking up");
                if(blockPos.z + 1 == CHUNK_SIZE) {
                    ChunkPos posU = ChunkPos(pos.x, pos.y, pos.z + 1);
                    if(chunk.world.loadedChunks.exists(posU)) {
                        Chunk@ cu = cast<Chunk@>(chunk.world.loadedChunks[posU]);
                        UpdateChunkBlockGraphics(@cu, Vector3I(blockPos.x, blockPos.y, 0), false);
                    }
                } else UpdateChunkBlockGraphics(@chunk, Vector3I(blockPos.x, blockPos.y, blockPos.z + 1), false);
            }
        }
    }
}