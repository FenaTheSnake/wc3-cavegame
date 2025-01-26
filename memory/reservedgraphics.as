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

    int AppendUsedGraphics(effect e) {
        int i = lastUsedGraphics;
        int searchEnd = (lastUsedGraphics == 0) ? (RESERVE_GRAPHICS_COUNT - 1) : (lastUsedGraphics - 1);
        while(i != searchEnd) {
            if(usedGraphics[i] != nil) {
                if(++i == RESERVE_GRAPHICS_COUNT) i = 0;
                continue;
            }
            usedGraphics[i] = e;
            lastUsedGraphics = i;
            return i;
        }

        return 0;
    }

    effect GetReservedGraphics(uint &out id) {
        if(lastUsedGraphics >= RESERVE_GRAPHICS_COUNT) {
            print("OUT OF ALLOCATED GRAPHICS!\nTry lower render distance.\n");
            DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "OUT OF ALLOCATED GRAPHICS!\nTry lower render distance.\n");
            return nil;
        }

        int i = lastFreeGraphics;
        int searchEnd = (lastFreeGraphics == 0) ? (RESERVE_GRAPHICS_COUNT - 1) : (lastFreeGraphics - 1);
        while(i != searchEnd) {
            if(reservedGraphics[i] == nil) {
                if(++i == RESERVE_GRAPHICS_COUNT) i = 0;
                continue;
            }
            //usedGraphics[lastUsedGraphics] = reservedGraphics[i];
            //id = lastUsedGraphics - 1;
            //lastUsedGraphics += 1;
            id = AppendUsedGraphics(reservedGraphics[i]);
            reservedGraphics[i] = nil;
            lastFreeGraphics = (lastFreeGraphics == RESERVE_GRAPHICS_COUNT - 1) ? (0) : (lastFreeGraphics + 1);

            return usedGraphics[id];
        }
        return nil;
    }


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
        int i = lastFreeGraphics;
        int searchEnd = (lastFreeGraphics == RESERVE_GRAPHICS_COUNT-1) ? (0) : (lastFreeGraphics + 1);
        while(i != searchEnd) {
            if(reservedGraphics[i] != nil) {
                if(--i == -1) i = RESERVE_GRAPHICS_COUNT - 1;
                continue;
            }
            reservedGraphics[i] = g;
            lastFreeGraphics = i;
            usedGraphics[id] = nil;

            SetSpecialEffectPositionWithZ(g, -9999, -9999, -9999);
            return;
        }
        

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
        // usedGraphics.removeAt(id);
        // freeGraphics.insertLast(g);

        // SetSpecialEffectPositionWithZ(g, -9999, -9999, -9999);
    }

}