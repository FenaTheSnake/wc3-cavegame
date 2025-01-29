#include "blizzard.as"
#include "constants.as"
#include "logger.as"
#include "memory\\memory.as"
#include "world\\world.as"
#include "collision\\collision.as"
#include "fpp\\firstpersonplayer.as"
#include "save\\worldsave.as"
#include "save\\global.as"
#include "mptest.as"
#include "gui\\gui.as"

namespace Main {
    int renderDistance = 4;
    int renderDistance_z = 3;

    // dynamically changed based on fps
    int toGenerateBlocks = MAX_GENERATED_BLOCKS_AT_ONCE;
    int toBuildBlocks = MAX_BUILT_BLOCKS_AT_ONCE;

    FPP::FirstPersonPlayer player;
    World::WorldInstance overworld;
    Save::WorldSave@ overworldSave;

    trigger trig_chatSave;


    void Update() {
        player.Update();
    }

    void LongUpdate() {
        overworld.ProcessRequestedToBuildChunks();
        overworld.UnloadUnrelevantChunksIfNecessary();

        toGenerateBlocks = MAX_GENERATED_BLOCKS_AT_ONCE - (50 - (GetFPS() - 14)) * (MAX_GENERATED_BLOCKS_AT_ONCE / 50);
        toBuildBlocks = MAX_BUILT_BLOCKS_AT_ONCE - (50 - (GetFPS() - 14)) * (MAX_BUILT_BLOCKS_AT_ONCE / 50);
        World::Generator::ProcessGeneratingChunks();
        World::Builder::ProcessBuildingChunks();
        Multiplayer::Update();

        string dbg = "FPS: " + GetFPS() + "\n";
        dbg += "Generating Chunks / Max Generated Blocks: " + World::Generator::chunksBeingGenerated.length() + " / " + toGenerateBlocks + "\n";
        dbg += "Building Chunks / Max Built Blocks: " + World::Builder::chunksBeingBuilt.length() + " / " + toBuildBlocks + "\n";
        dbg += "Chunk Pool Used / Free / Capacity: " + Memory::chunkPool.usedChunks.length() + " / " + Memory::chunkPool.freeChunks.length() + " / " + Memory::chunkPool.currentCapacity + "\n";
        dbg += "Player Position: " + player.absolute_position + "; Chunk: " + World::AbsolutePositionToChunkPos(player.absolute_position) + "\n"; 
        dbg += "Player Motion: " + player.motion + "\n"; 
        ClearTextMessages();
        DisplayTextToPlayer(GetLocalPlayer(), 0, 0, dbg);
    }

    void GUIUpdate() {
        player.UpdateBlockSelection();
    }

    void FuckMe() {
        if(overworld.repositionBuiltChunksWhenYouAreReadyPleaseNoPressureJustDoItButPreferablyDoItSoonerOk) {
            overworld.UpdateBuiltChunksPositions();
            overworld.repositionBuiltChunksWhenYouAreReadyPleaseNoPressureJustDoItButPreferablyDoItSoonerOk = false;
        }
    }

    void PeersSyncUpdate() {
        Multiplayer::SyncAllPeersPositions();
    }


    void HideWarcraftInterface() {
        HideOriginFrames(true);
        EditBlackBorders(0, 0);
    }

    void StartGame(Save::WorldSave@ save) {
        Memory::Init();
        GUI::Init();

        @overworldSave = @save;
        @overworld.worldSave = @save;

        player.Init(@overworld, Vector3(-512, 512, 1024));

        TimerStart(CreateTimer(), 0.01f, true, @Update);
        TimerStart(CreateTimer(), 0.05f, true, @LongUpdate);
        TimerStart(CreateTimer(), 0.15f, true, @GUIUpdate);
        TimerStart(CreateTimer(), 0.20f, true, @PeersSyncUpdate);
        TimerStart(CreateTimer(), 0.50f, true, @FuckMe);
    }


    void PostInit() {
        HideWarcraftInterface();
        SetWidescreenState(true);

        Multiplayer::Init();

        GUI::Menus::Attention::Init();
        GUI::Menus::WorldCreation::Init();

        if(Multiplayer::isHost) GUI::Menus::WorldCreation::Show();
        else GUI::Menus::Attention::AddAttention(ATTENTION_WAITING_FOR_HOST);
    }

    void Init() {
        SetSkyModel("war3mapImported\\skyLight.mdx");

        FogEnable(false);
        FogMaskEnable(false);

        SetCameraField(CAMERA_FIELD_ZOFFSET, 0.0f, 0.0f);
        SetCameraField(CAMERA_FIELD_ANGLE_OF_ATTACK, 0.0f, 0.0f);
        SetCameraField(CAMERA_FIELD_TARGET_DISTANCE, 0.0f, 0.0f);
        SetCameraField(CAMERA_FIELD_FIELD_OF_VIEW, 100.0f, 0.0f);
        SetCameraField(CAMERA_FIELD_FARZ, 8000.0f, 0.0f);

        SetFloatGameState(GAME_STATE_TIME_OF_DAY, 12);

        TimerStart(CreateTimer(), 0.1f, false, @PostInit);
    }

    void Config() {
        
    }
}