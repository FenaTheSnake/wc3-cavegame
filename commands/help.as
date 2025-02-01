namespace Commands {
    namespace Help {
        void OnCommandSent(array<string>@ args, player p) {

            if(p == GetLocalPlayer()) {
                DisplayTextToPlayer(p, 0, 0, "/help - show commands\n/tp <x> <y> <z> - teleport to coords");
            }

        }
    }
}