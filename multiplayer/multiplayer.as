namespace Multiplayer {
    bool isHost;

    void Init() {
        isHost = GetHostPlayer() == GetLocalPlayer();
    }
}