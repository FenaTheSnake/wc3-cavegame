namespace Multiplayer {
    enum PeerAnimation {
        IDLE,
        WALKING
    }

    // other player entity
    class Peer {
        effect model;
        Vector3 position;
        Vector3 visual_position;
        player p;

        float facing;
        float visual_facing;

        PeerAnimation anim = PeerAnimation::IDLE;
        float customAnimTimer = 0.0f;   // if > 0, IDLE and WALK animations would not be played

        Peer(player p) {
            model = AddSpecialEffect("Units\\Human\\Peasant\\peasant.mdx", 0.0f, 0.0f);
            position = Vector3(0, 0, 0);
            facing = 0.0f;
            this.p = p;

            SetSpecialEffectPlayerColour(model, ConvertPlayerColor(GetPlayerId(p)));
            SetSpecialEffectScale(model, 2.0f);
        }

        void UpdateModel() {
            Vector3 pos = World::AbsolutePositionToWC3Position(visual_position, true);
            SetSpecialEffectPositionWithZ(model, pos.x, pos.y, pos.z - (PLAYER_HEIGHT / 2));
            SetSpecialEffectFacing(model, visual_facing);

            float dist = Vector3Distance(position, visual_position);
            if(dist > 16.0f) {
                if(anim == PeerAnimation::IDLE) {
                    anim = PeerAnimation::WALKING;
                    if(customAnimTimer <= 0.0f) SetSpecialEffectAnimation(model, "walk");
                }
                if(customAnimTimer <= 0.0f) SetSpecialEffectTimeScale(model, (dist - 16.0f) / 2048.0f);
            } else {
                if(anim == PeerAnimation::WALKING) {
                    anim = PeerAnimation::IDLE;
                    if(customAnimTimer <= 0.0f) {
                        SetSpecialEffectTimeScale(model, 1.0f);
                        SetSpecialEffectAnimation(model, "stand");
                    }
                }
            }

            if(customAnimTimer > 0.0f) customAnimTimer -= 0.05f;
            if(customAnimTimer <= 0.0f) {
                if(anim == PeerAnimation::IDLE) SetSpecialEffectAnimation(model, "stand");
                if(anim == PeerAnimation::WALKING) SetSpecialEffectAnimation(model, "walk");
            }
        }

        void PlayAnimation(string &in animName, float playbackTime) {
            SetSpecialEffectTimeScale(model, 1.0f);
            SetSpecialEffectAnimation(model, animName);
            customAnimTimer = playbackTime;
        }
    }

    array<Peer@> peers;

    // syncs your position and updates peers positions
    void SyncAllPeersPositions() {
        Vector3 myPos = Main::player.absolute_position;
        SaveReal(syncHT, GetPlayerId(GetLocalPlayer()), MP_SYNCHT_POS_X, myPos.x);
        SyncSavedReal(syncHT, GetPlayerId(GetLocalPlayer()), MP_SYNCHT_POS_X);
        SaveReal(syncHT, GetPlayerId(GetLocalPlayer()), MP_SYNCHT_POS_Y, myPos.y);
        SyncSavedReal(syncHT, GetPlayerId(GetLocalPlayer()), MP_SYNCHT_POS_Y);
        SaveReal(syncHT, GetPlayerId(GetLocalPlayer()), MP_SYNCHT_POS_Z, myPos.z);
        SyncSavedReal(syncHT, GetPlayerId(GetLocalPlayer()), MP_SYNCHT_POS_Z);
        SaveReal(syncHT, GetPlayerId(GetLocalPlayer()), MP_SYNCHT_FACING, Main::player.targetFacing.x);
        SyncSavedReal(syncHT, GetPlayerId(GetLocalPlayer()), MP_SYNCHT_FACING);

        for(int i = 0; i < peers.length(); i++) {
            if(i == GetPlayerId(GetLocalPlayer())) continue;
            peers[i].position.x = LoadReal(syncHT, GetPlayerId(players[i]), MP_SYNCHT_POS_X);
            peers[i].position.y = LoadReal(syncHT, GetPlayerId(players[i]), MP_SYNCHT_POS_Y);
            peers[i].position.z = LoadReal(syncHT, GetPlayerId(players[i]), MP_SYNCHT_POS_Z);
            peers[i].facing = LoadReal(syncHT, GetPlayerId(players[i]), MP_SYNCHT_FACING);
        }
    }

    void UpdatePeers() {
        for(int i = 0; i < peers.length(); i++) {
            if(i == GetPlayerId(GetLocalPlayer())) continue;

            peers[i].visual_position.x = expDecay(peers[i].visual_position.x, peers[i].position.x, 20.0f, 1.0f/60.0f);
            peers[i].visual_position.y = expDecay(peers[i].visual_position.y, peers[i].position.y, 20.0f, 1.0f/60.0f);
            peers[i].visual_position.z = expDecay(peers[i].visual_position.z, peers[i].position.z, 20.0f, 1.0f/60.0f);
            peers[i].visual_facing = expDecay(peers[i].visual_facing, peers[i].facing, 20.0f, 1.0f/60.0f);
            peers[i].UpdateModel();
        }
    }
}