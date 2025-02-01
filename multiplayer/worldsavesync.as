namespace Multiplayer {
    namespace WorldSaveSync {

        array<string>@ chunksToSync;
        int syncingChunkCounter = 0;

        Save::WorldSave@ syncingWorld;

        timer syncTimer;

        void SyncWorldSave(string name) {
            syncTimer = CreateTimer();
            TimerStart(syncTimer, 0.25f, true, @SyncNextChunk);

            if(isHost) {
                @syncingWorld = @Save::OpenWorldSave(name);
                if(syncingWorld == null) {
                    __debug("(SyncWorldSave) Can't open world: " + name);
                    return;
                }

                @chunksToSync = @syncingWorld.GetAllSavedChunks();
                syncingChunkCounter = 0;

                __debug("syncworldsave end");
            } else {
                @syncingWorld = @Save::CreateWorldSaveWithFreeName(name);
                syncingWorld.BeginSaving();
            }

        }

        void SyncNextChunk() {
            if(!isHost) return;
            __debug("syncing " + syncingChunkCounter + " " + chunksToSync[syncingChunkCounter]);
            uint id = uint(syncingWorld.savedChunks[chunksToSync[syncingChunkCounter]]);
            string data = TextFileReadLine(syncingWorld.chunksFiles[UINTID2ChunkFileID(id)].file, UINTID2ChunkID(id));

            SendSyncData(MP_SYNCCHUNK_PREFIX, data);
            syncingChunkCounter += 1;
            GUI::Menus::Attention::UpdateAttention(ATTENTION_SYNCING_WORLD, ATTENTION_SYNCING_WORLD_TEXT + syncingWorld.name + "\n" + syncingChunkCounter + "/" + chunksToSync.length());
            
            if(syncingChunkCounter >= chunksToSync.length()) {
                PauseTimer(syncTimer);
                SendSyncData(MP_SYNCWORLD_END_PREFIX, "y");
            }
        }

        void OnSyncChunk() {
            if(isHost) return;
            string data = GetTriggerSyncData();

            syncingWorld.AddSerializedChunk(data);
            syncingChunkCounter += 1;
            GUI::Menus::Attention::UpdateAttention(ATTENTION_SYNCING_WORLD, ATTENTION_SYNCING_WORLD_TEXT + syncingWorld.name + "\n" + syncingChunkCounter + "/?");
        }

        void OnSyncWorldEnd() {
            __debug("syncying end");
            GUI::Menus::Attention::RemoveAttention(ATTENTION_SYNCING_WORLD);
            if(!isHost) syncingWorld.FinishSaving();

            Main::StartGame(@syncingWorld);
        }
    }
}