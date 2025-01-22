namespace Memory {

    // all players should have same handles created even if they are seeing different things
    // i.e. we cant create handles on demand and must create them once for all players so it is synchronized
    // and then we can use them with async funcs (changing graphics, position, etc.)

    // class ReservedGraphics {
    //     effect eff;
    //     bool used;
    //     uint id;

    //     ReservedGraphics() {}
    //     ReservedGraphics(effect eff) {
    //         this.eff = eff;
    //     }
    // }

    array<effect> reservedGraphics(RESERVE_GRAPHICS_COUNT);

    // and these are the same handles but more conveniet
    //array<effect> freeGraphics(RESERVE_GRAPHICS_COUNT);
    int lastFreeGraphics = 0;
    array<effect> usedGraphics(RESERVE_GRAPHICS_COUNT);
    int lastUsedGraphics = 0;

    void AllocateReservedGraphics() {
        for(int i = 0; i < RESERVE_GRAPHICS_COUNT; i++) {
            reservedGraphics[i] = AddSpecialEffect("block.mdx", -9999, -9999);
            SetSpecialEffectZ(reservedGraphics[i], -9999);
        }
    }

    effect GetReservedGraphics(uint &out id) {
        


    //     if(freeGraphics.length() <= 0) {
    //         print("OUT OF ALLOCATED GRAPHICS!\nTry lower render distance.\n");
    //         DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "OUT OF ALLOCATED GRAPHICS!\nTry lower render distance.\n");
    //         return nil;
    //     }

    //     effect g = freeGraphics[freeGraphics.length() - 1];
    //     //if(Main::_debugRD !is null && g is Main::_debugRD) __debug("yep");
    //     freeGraphics.removeLast();

    //     id = usedGraphics.length();
    //     //if(id == 0) __debug("get id " + id);
    //     usedGraphics.insertLast(g);

    //     return g;
    // }
    void FreeReservedGraphics(effect &in g, uint &in id) {
        // int p = usedGraphics.find(g);
        // if(p < 0) { 
        //     __debug("effect not found");
        //     return ;
        // }

        //BenchmarkReset();
        //BenchmarkStart();
        // int i;
        // for(i = 0; i < usedGraphics.length(); i++) {
        //     if(usedGraphics[i] == g) break;
        // }
        // if(i == usedGraphics.length()) {
        //     BenchmarkEnd();
        //     return;
        // }
        //__debug("found");
        //BenchmarkEnd();
        //__debug("search took " + BenchmarkGetElapsed(2) + " ms.");

        //if(id == -1) return;
        //__debug("id " + id + " / " + usedGraphics.length());
        usedGraphics.removeAt(id);
        freeGraphics.insertLast(g);

        SetSpecialEffectPositionWithZ(g, -9999, -9999, -9999);
    }

}