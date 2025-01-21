namespace Memory {

    // all players should have same handles created even if they are seeing different things
    // i.e. we cant create handles on demand and must create them once for all players so it is synchronized
    // and then we can use them with async funcs (changing graphics, position, etc.)
    class ReservedGraphics {
        effect eff;
        bool used;
        uint id;

        ReservedGraphics() {}
        ReservedGraphics(effect eff) {
            this.eff = eff;
        }
    }

    array<ReservedGraphics> reservedGraphics(RESERVE_GRAPHICS_COUNT);

    // and these are the same handles but more conveniet
    array<ReservedGraphics@> freeGraphics;
    array<ReservedGraphics@> usedGraphics;

    void AllocateReservedGraphics() {
        for(int i = 0; i < RESERVE_GRAPHICS_COUNT; i++) {
            reservedGraphics[i] = ReservedGraphics(AddSpecialEffect("block.mdx", -9999, -9999));
            SetSpecialEffectZ(reservedGraphics[i].eff, -9999);

            freeGraphics.insertLast(@reservedGraphics[i]);
        }
    }

    ReservedGraphics@ GetReservedGraphics() {
        if(freeGraphics.length() <= 0) {
            print("OUT OF ALLOCATED GRAPHICS!\nTry lower render distance.\n");
            DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "OUT OF ALLOCATED GRAPHICS!\nTry lower render distance.\n");
            return null;
        }

        ReservedGraphics@ g = freeGraphics[freeGraphics.length() - 1];
        //if(Main::_debugRD !is null && g is Main::_debugRD) __debug("yep");
        freeGraphics.removeLast();

        //g.id = usedGraphics.length();
        usedGraphics.insertLast(g);

        return g;
    }
    void FreeReservedGraphics(ReservedGraphics@ g) {
        int p = usedGraphics.findByRef(g);
        if(p < 0) return;

        usedGraphics.removeAt(p);
        freeGraphics.insertLast(g);

        SetSpecialEffectPositionWithZ(g.eff, -9999, -9999, -9999);
    }

}