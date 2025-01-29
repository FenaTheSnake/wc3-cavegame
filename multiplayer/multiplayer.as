#include "syncrequests.as"
#include "peer.as"

namespace Multiplayer {
    bool isHost;
    trigger trig_SetBlock;
    trigger trig_CreateWorld;

    hashtable syncHT;
    array<player> players;

    void Init() {
        isHost = GetHostPlayer() == GetLocalPlayer();
        syncHT = InitHashtable();

        trig_SetBlock = CreateTrigger();
        trig_CreateWorld = CreateTrigger();
        for(int i = 0; i < 12; i++) {
            if(GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING) {
                players.insertLast(Player(i));
                peers.insertLast(@Peer(Player(i)));

                TriggerRegisterPlayerSyncEvent(trig_SetBlock, Player(i), MP_SETBLOCK_PREFIX, false);
                TriggerRegisterPlayerSyncEvent(trig_SetBlock, Player(i), MP_SETBLOCK_PREFIX, true);
                TriggerRegisterPlayerSyncEvent(trig_CreateWorld, Player(i), MP_CREATEWORLD_PREFIX, true);
            }
        }
        SetSpecialEffectPositionWithZ(peers[GetPlayerId(GetLocalPlayer())].model, -9999, -9999, -9999);
        TriggerAddAction(trig_SetBlock, @OnSetBlock);
        TriggerAddAction(trig_CreateWorld, @OnCreateWorld);
    }

    void Update() {
        SyncRequests::ProcessRequests();
        UpdatePeers();
    }

    void SendSetBlock(World::BlockPos &in blockPos, World::BlockID id) {
        string data = (blockPos.x+blockPos.chunk.position.x*CHUNK_SIZE) + "|" + (blockPos.y+blockPos.chunk.position.y*CHUNK_SIZE) + "|" + (blockPos.z+blockPos.chunk.position.z*CHUNK_SIZE) + "|" + id;
        SendSyncData(MP_SETBLOCK_PREFIX, data);
    }

    void OnSetBlock() {
        string data = GetTriggerSyncData();
        
        array<string>@ ss = data.split("|");
        World::BlockPos bpos = World::BlockPos(parseInt(ss[0]), parseInt(ss[1]), parseInt(ss[2]));
        @bpos.chunk = @Main::overworld.GetChunkByBlockPos(bpos);
        SyncRequests::AddSetBlockRequest(bpos, World::BlockID(parseInt(ss[3])));

        if(GetTriggerPlayer() != GetLocalPlayer()) {
            //SetSpecialEffectAnimation(peers[GetPlayerId(GetTriggerPlayer())].model, "attack");
            peers[GetPlayerId(GetTriggerPlayer())].PlayAnimation("attack", 0.5f);
        }
    }

    void SendCreateNewWorld(string name) {
        string data = name;
        SendSyncData(MP_CREATEWORLD_PREFIX, data);
    }

    void OnCreateWorld() {
        string data = GetTriggerSyncData();

        Main::StartGame(@Save::CreateWorldSaveWithFreeName(data));
        GUI::Menus::Attention::RemoveAttention(ATTENTION_WAITING_FOR_HOST);
    }
}

// namespace Multiplayer {
//     bool isHost;
//     trigger trig_ChunkSyncRequest;
//     trigger trig_ChunkSyncAnswer;

//     void Init() {
//         isHost = GetHostPlayer() == GetLocalPlayer();

//         trig_ChunkSyncRequest = CreateTrigger();
//         for(int i = 0; i < 12; i++) {
//             TriggerRegisterPlayerSyncEvent(trig_ChunkSyncRequest, Player(i), MP_CHUNK_SYNC_REQUEST_PREFIX, false);
//         }
//         TriggerAddAction(trig_ChunkSyncRequest, @OnChunkSyncRequest);

//         trig_ChunkSyncAnswer = CreateTrigger();
//         for(int i = 0; i < 12; i++) {
//             TriggerRegisterPlayerSyncEvent(trig_ChunkSyncAnswer, Player(i), MP_CHUNK_SYNC_ANSWER_PREFIX, true);
//         }
//         TriggerAddAction(trig_ChunkSyncAnswer, @OnChunkSyncAnswer);
//     }

//     World::Chunk@ RequestChunk(World::ChunkPos &in pos) {
//         SendSyncData(MP_CHUNK_SYNC_REQUEST_PREFIX, pos);
//         __debug("sent sync chunk request " + pos);

//         World::Chunk@ chunk = @Memory::chunkPool.GetChunk();
//         chunk.position = pos;
//         chunk.on_map_position = World::ChunkPosToWC3Position(chunk.position);
//         @chunk.world = @Main::overworld;
//         chunk.generationState = World::ChunkGenerationState::REQUESTED;

//         return chunk;
//     }

//     void OnChunkSyncRequest() {
//         if(!isHost) return;

//         string data = GetTriggerSyncData();
//         __debug("got chunk request: " + data);
//         SyncRequests::AddChunkSyncRequest(World::ChunkPos(data), @Main::overworld);
//     }

//     void OnChunkSyncAnswer() {
//         if(isHost) return;

//         string data = GetTriggerSyncData();
//         __debug("got chunk answer");

//         array<string>@ ss = data.split("|");
//         World::ChunkPos pos = World::ChunkPos(parseInt(ss[0]), parseInt(ss[1]), parseInt(ss[2]));

//         if(Main::overworld.loadedChunks.exists(pos)) {
//             World::Chunk@ chunk = cast<World::Chunk@>(Main::overworld.loadedChunks[pos]);
//             chunk.Deserialize(data);
//             if(chunk.generationState >= World::ChunkGenerationState::BUILDING) {
//                 chunk.world.UnloadChunk(chunk.position);
//             }
//             chunk.generationState = World::ChunkGenerationState::GENERATED;
//         } else {
//             World::Chunk@ chunk = @Memory::chunkPool.GetChunk();
//             chunk.Deserialize(data);
//             chunk.on_map_position = World::ChunkPosToWC3Position(chunk.position);
//             @chunk.world = @Main::overworld;
//             chunk.generationState = World::ChunkGenerationState::GENERATED;
//         }
//     }

//     void Update() {
//         SyncRequests::ProcessRequests();
//     }
// }