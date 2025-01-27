namespace Multiplayer {
    namespace SyncRequests {
        class RequestedSetBlock {
            World::BlockPos position;
            World::BlockID blockID;
            RequestedSetBlock(World::BlockPos &in bpos, World::BlockID &in bid) {
                position = bpos;
                blockID = bid;
            }
        }

        array<RequestedSetBlock@> requestedSetBlocks;

        void AddSetBlockRequest(World::BlockPos &in pos, World::BlockID &in id) {
            requestedSetBlocks.insertLast(@RequestedSetBlock(pos, id));
        }

        void ProcessRequests() {

            for(int i = 0; i < requestedSetBlocks.length(); i++) {
                RequestedSetBlock@ req = @requestedSetBlocks[i];

                if(req.position.chunk == null) {
                    @req.position.chunk = @Main::overworld.RequestChunk(Main::overworld.GetChunkPosByBlockPos(req.position));
                } else {
                    if(Main::overworld.loadedChunks.exists(req.position.chunk.position)) {
                        //World::Chunk@ chunk = Main::overworld.loadedChunks[req.position];
                        if(req.position.chunk.generationState >= World::ChunkGenerationState::GENERATED) {
                            req.position.chunk.SetBlock(Main::overworld.GetBlockByAbsoluteBlockPos(req.position), req.blockID);
                            requestedSetBlocks.removeAt(i--);
                        } else if(req.position.chunk.generationState < World::ChunkGenerationState::REQUESTED) {
                            requestedSetBlocks.removeAt(i--);
                        }
                    } else {
                        requestedSetBlocks.removeAt(i--);
                    }
                }
            }

        }
    }
}

    //     class ChunkSyncRequest {
    //         World::ChunkPos position;
    //         World::WorldInstance@ world;
    //         ChunkSyncRequest(World::ChunkPos &in pos, World::WorldInstance@ &in world) {
    //             this.position = pos;
    //             @this.world = @world;
    //         }
    //     }

    //     array<ChunkSyncRequest@> chunkSyncRequests;

    //     void ProcessRequests() {

    //         for(int i = 0; i < chunkSyncRequests.length(); i++) {
    //             ChunkSyncRequest@ req = @chunkSyncRequests[i];

    //             if(req.world.loadedChunks.exists(req.position)) {
    //                 World::Chunk@ chunk = cast<World::Chunk@>(req.world.loadedChunks[req.position]);
    //                 if(chunk.generationState >= World::ChunkGenerationState::GENERATED) {
    //                     __debug("sent sync chunk answer " + req.position);
    //                     SendSyncData(MP_CHUNK_SYNC_ANSWER_PREFIX, chunk.Serialize());
    //                     __debug("sent");

    //                     chunkSyncRequests.removeAt(i--);
    //                 } else if(chunk.generationState < World::ChunkGenerationState::GENERATING) {
    //                     chunkSyncRequests.removeAt(i--);
    //                 }
    //             } else {
    //                 Main::overworld.RequestChunk(req.position);
    //             }
    //         }

    //     }

    //     void AddChunkSyncRequest(World::ChunkPos &in pos, World::WorldInstance@ &in world) {
    //         chunkSyncRequests.insertLast(@ChunkSyncRequest(pos, world));
    //     }
    // }
//}