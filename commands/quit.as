namespace Commands {
    namespace Quit {
        void OnCommandSent(array<string>@ args, player p) {

            if(p == GetLocalPlayer() && Multiplayer::isHost) {
                Multiplayer::SendEndGame();
            }

        }
    }
}