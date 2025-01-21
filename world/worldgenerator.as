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

                            if(p.z*CHUNK_SIZE+k <= (p.x*CHUNK_SIZE+i) / 10) data.chunk.blocks[i][j][k] = Block(BlockID::GRASS);
                            else data.chunk.blocks[i][j][k] = Block(BlockID::AIR);

                            // if((i == 0 && j == 0) || (j == 0 && k == 0) || (i == 0 && k == 0)) data.chunk.blocks[i][j][k] = Block(BlockID::EARTH);
                            // else data.chunk.blocks[i][j][k] = Block(BlockID::AIR);

                        }
                    }
                }

                data.chunk.generationState = ChunkGenerationState::GENERATED;
                chunksBeingGenerated.removeAt(chunk_iter);
                chunk_iter--;

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
    }
}