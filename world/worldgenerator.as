namespace World {
    namespace Generator {
        class GeneratingChunkData {
            Chunk@ chunk;
            uint i, j ,k;    // block that we ended at last time

            GeneratingChunkData() {}
            GeneratingChunkData(Chunk@ chunk) {
                @this.chunk = @chunk;
                i = 0; j = 0; k = 0;
            }
        }

        int seed = 4467878;
        array<GeneratingChunkData> chunksBeingGenerated;
        
        int processedGeneratingBlocks = 0;
        void ProcessGeneratingChunks() {
            processedGeneratingBlocks = 0;

            for(uint chunk_iter = 0; chunk_iter < chunksBeingGenerated.length(); chunk_iter++) {
                GeneratingChunkData@ data = @chunksBeingGenerated[chunk_iter];
                if(data.chunk.generationState != ChunkGenerationState::GENERATING) {
                    chunksBeingGenerated.removeAt(chunk_iter);
                    chunk_iter--;
                    continue;
                }

                for(uint i = 0; i < CHUNK_SIZE; i++) {
                    for(uint j = 0; j < CHUNK_SIZE; j++) {
                        for(uint k = 0; k < CHUNK_SIZE; k++) {
                            if(data.i != 0 || data.j != 0 || data.k != 0) {
                                i = data.i; j = data.j; k = data.k;
                                data.i = 0; data.j = 0; data.k = 0;
                            }
                            
                            processedGeneratingBlocks++;
                            if(processedGeneratingBlocks > Main::toGenerateBlocks) {
                                data.i = i; data.j = j; data.k = k;
                                return;
                            }

                            ChunkPos@ p = @data.chunk.position;

                            //if(p.x == 3 && p.y == 3 && p.z == 3) data.chunk.blocks[i][j][k] = Block(BlockID::GRASS);
                            //else data.chunk.blocks[i][j][k] = Block(BlockID::AIR);

                            // if( (p.x > -1 && p.y < 1 && p.z == 0 && k == 0) ||
                            //     (p.x > -1 && p.y < 1 && p.z == -1))
                            //     data.chunk.blocks[i][j][k] = Block(BlockID::GRASS);
                            // else data.chunk.blocks[i][j][k] = Block(BlockID::AIR);

                            float gx = p.x*CHUNK_SIZE+i;
                            float gy = p.y*CHUNK_SIZE+j;
                            float gz = p.z*CHUNK_SIZE+k;
                            float ovNoise = OverworldNoise(gx, gy);
                            if(gz > ovNoise - 30.0f) {
                                if(gz < ovNoise) {
                                    data.chunk.blocks[i][j][k] = BlockID::GRASS;
                                    if(k > 0) {
                                        if(data.chunk.blocks[i][j][k-1] == BlockID::GRASS)
                                            data.chunk.blocks[i][j][k-1] = BlockID::DIRT;
                                    }
                                }
                                else if(gz == int(ovNoise)) {
                                    MaybePlaceTree(gx, gy, gz);
                                }
                                else data.chunk.blocks[i][j][k] = BlockID::AIR;
                            } else {
                                float ugNoise = UndergroundNoise(gx, gy, gz);
                                if(ugNoise <= -3.064f) data.chunk.blocks[i][j][k] = BlockID::AIR;
                                else data.chunk.blocks[i][j][k] = BlockID::STONE;
                            }

                            // if((i == 0 && j == 0) || (j == 0 && k == 0) || (i == 0 && k == 0)) data.chunk.blocks[i][j][k] = Block(BlockID::EARTH);
                            // else data.chunk.blocks[i][j][k] = Block(BlockID::AIR);

                        }
                    }
                }

                data.chunk.generationState = ChunkGenerationState::GENERATED;
                chunksBeingGenerated.removeAt(chunk_iter);
                chunk_iter--;

                data.chunk.world.ProcessScheduledBlocks();
            }
        }

        // Initializes a new chunk and sends it to list of chunks to be generated later.
        // thus the returned chunk is not ready to be used!
        Chunk@ GenerateChunk(const ChunkPos &in position, WorldInstance@ world) {
            Chunk@ chunk = @Memory::chunkPool.GetChunk();
            chunk.position = position;
            chunk.on_map_position = World::ChunkPosToWC3Position(chunk.position);
            @chunk.world = @world;
            chunk.generationState = ChunkGenerationState::GENERATING;

            chunksBeingGenerated.insertLast(GeneratingChunkData(@chunk));

            return chunk;
        }

        float OverworldNoise(float x, float y) {
            //float terrain1 = noise3(x * 0.01743f, y * 0.017212f, seed) * 5.0f;
            float terrain2 = noise3(x * 0.002023f, y * 0.00257809f, seed) * 20.0f;
            float terrain3 = noise3(x * 0.0553335f, y * 0.0449839f, seed) * 5.233f;
            return terrain2+terrain3;
        }
        float UndergroundNoise(float x, float y, float z) {
            return noise4(x * 0.0853f, y * 0.1007, z*0.0914403, seed) * 16.2f;
        }

        // places a block in generated chunk or schedules block placement for when chunk is generated
        // used for structures generation
        void PlaceOrScheduleBlock(int x, int y, int z, BlockID id) {
            BlockPos bpos = Main::overworld.GetBlockByAbsoluteBlockPos(BlockPos(x, y, z));

            if(bpos.chunk != null) {
                if(bpos.chunk.generationState >= ChunkGenerationState::GENERATED) {
                    bpos.chunk.SetBlock(bpos, id);
                    return;
                }
            }

            Main::overworld.ScheduleBlock(bpos, id);
        }

        void MaybePlaceTree(float x, float y, float z) {
            float n = noise3(x * 0.0161f, y * 0.008883f, seed);
            float n2 = noise3(x * 0.43f, y * 0.733f, seed*2);
            if(n+n2 >= 0.75f) {
                PlaceOrScheduleBlock(x, y, z , BlockID::LOG);
                PlaceOrScheduleBlock(x, y, z + 1, BlockID::LOG);
                PlaceOrScheduleBlock(x, y, z + 2, BlockID::LOG);
                PlaceOrScheduleBlock(x, y, z + 3, BlockID::LOG);
                PlaceOrScheduleBlock(x, y, z + 4, BlockID::LOG);
                PlaceOrScheduleBlock(x, y, z + 5, BlockID::LOG);

                PlaceOrScheduleBlock(x, y, z + 6, BlockID::LEAVES);

                for(int i = -1; i <= 1; i++) {
                    for(int j = -1; j <= 1; j++) {
                        if(i == j) continue;
                        PlaceOrScheduleBlock(x + i, y + j, z + 5, BlockID::LEAVES);
                    }
                }

                for(int i = -2; i <= 2; i++) {
                    for(int j = -2; j <= 2; j++) {
                        if(i == 0 && j == 0) continue;
                        PlaceOrScheduleBlock(x + i, y + j, z + 4, BlockID::LEAVES);
                    }
                }

                for(int i = -2; i <= 2; i++) {
                    for(int j = -2; j <= 2; j++) {
                        if(i == 0 && j == 0) continue;
                        PlaceOrScheduleBlock(x + i, y + j, z + 3, BlockID::LEAVES);
                    }
                }
            }
        }
    }
}