#include "blizzard.as"
#include "constants.as"
#include "logger.as"
#include "memory\\memory.as"
#include "world\\world.as"
#include "collision\\collision.as"
#include "fpp\\firstpersonplayer.as"

namespace Main {
    int renderDistance = 4;
    int renderDistance_z = 3;

    //Memory::ReservedGraphics@ _debugRD;

    // dynamically changed based on fps
    int toGenerateBlocks = MAX_GENERATED_BLOCKS_AT_ONCE;
    int toBuildBlocks = MAX_BUILT_BLOCKS_AT_ONCE;

    FPP::FirstPersonPlayer player;
    World::WorldInstance overworld;


    void Update() {
        player.Update();
    }

    void LongUpdate() {
        overworld.ProcessRequestedToBuildChunks();

        toGenerateBlocks = MAX_GENERATED_BLOCKS_AT_ONCE - (50 - (GetFPS() - 14)) * (MAX_GENERATED_BLOCKS_AT_ONCE / 50);
        toBuildBlocks = MAX_BUILT_BLOCKS_AT_ONCE - (50 - (GetFPS() - 14)) * (MAX_BUILT_BLOCKS_AT_ONCE / 50);
        World::Generator::ProcessGeneratingChunks();
        World::Builder::ProcessBuildingChunks();

        string dbg = "FPS: " + GetFPS() + "\n";
        dbg += "Generating Chunks / Max Generated Blocks: " + World::Generator::chunksBeingGenerated.length() + " / " + toGenerateBlocks + "\n";
        dbg += "Building Chunks / Max Built Blocks: " + World::Builder::chunksBeingBuilt.length() + " / " + toBuildBlocks + "\n";
        dbg += "Chunk Pool Used / Free / Capacity: " + Memory::chunkPool.usedChunks.length() + " / " + Memory::chunkPool.freeChunks.length() + " / " + Memory::chunkPool.currentCapacity + "\n";
        dbg += "Player Position: " + player.absolute_position + "; Chunk: " + World::AbsolutePositionToChunkPos(player.absolute_position) + "\n"; 
        dbg += "Player Motion: " + player.motion + "\n"; 
        ClearTextMessages();
        DisplayTextToPlayer(GetLocalPlayer(), 0, 0, dbg);

        // if(_debugRD !is null) {

        //     __debug("debug rd: " + GetSpecialEffectX(_debugRD.eff) + " " + GetSpecialEffectY(_debugRD.eff) + " " + GetSpecialEffectZ(_debugRD.eff));
        // }

        //__debug("Requested To Build Chunks: " + overworld.requestedToBuildChunks.length() + "\nProcessing Generating Chunks: " + World::Generator::chunksBeingGenerated.length() + "\nProcessing Building Chunks: " + World::Builder::chunksBeingBuilt.length());
    }

    void Test() {
        string s = cast<World::Chunk@>(overworld.loadedChunks[World::ChunkPos(0, 0, 0)]).Serialize();
        __debug(s);
    }

    void HideWarcraftInterface() {
        HideOriginFrames(true);
        EditBlackBorders(0, 0);
    }

    // class ReferencedClass {
    //     int doesntmatter;
    // }
    // class ClassInArray {
    //     weakref<ReferencedClass> c;
    // }
    // class ClassWithBigArray {
    //     //ReferencedClass@ rc;
    //     //array<ClassInArray> bigArray(16*16*16*10);
    //     int haha=0;

    //     ClassWithBigArray() {
    //         abc++;
    //     }
    // }

    // void DoSomething(ClassWithBigArray@ cl) {
    //     //cl.bigArray[34].c.get().doesntmatter = 1;
    // }

    // array<int> carr(4000000);
    // array<int> carr2(400000);
    // array<int> carr3(400000);
    // int64 last = 0;
    // int64 abc = 0;
    // void Upd() {
    //     // for(int i = last; i < last + 100000; i++) {
    //     //     carr[i] = ClassWithBigArray();
    //     //     //DoSomething(@c);
    //     //     //abc += c.bigArray.length();
    //     // }
    //     // last += 100000;
    //     // __debug(abc + "");
    // }


    void PostInit() {
        HideWarcraftInterface();
        Multiplayer::Init();
        Memory::Init();
        player.Init(@overworld, Vector3(-512, 512, 1024));

        TimerStart(CreateTimer(), 0.01f, true, @Update);
        TimerStart(CreateTimer(), 0.05f, true, @LongUpdate);
        //TimerStart(CreateTimer(), 5.00f, false, @Test);
    }

    // class ReferencedClass {
    //     int doesntmatter;
    // }
    // class ClassInArray {
    //     weakref<ReferencedClass> c;
    // }
    // class ClassWithBigArray {
    //     array<ClassInArray> bigArray(16*16*16*50);
    // }

    // void Upd() {
    //     ClassWithBigArray c = ClassWithBigArray();
    // }

    void Init() {
        //TimerStart(CreateTimer(), 0.5f, true, @Upd);
        //return;

        SetSkyModel("war3mapImported\\skyLight.mdx");

        for(int i = 0; i < 12; i++) {
            //fogmodifier f = CreateFogModifierRect(Player(i), FOG_OF_WAR_VISIBLE, GetWorldBounds(), true, false);
            //FogModifierStart(f);
        }

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

    void config() {

    }
}