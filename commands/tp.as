namespace Commands {
    namespace Teleport {
        void OnCommandSent(array<string>@ args, player p) {

            if(p == GetLocalPlayer()) {
                if(args.length() == 4) {
                    Vector3 p = Vector3(parseFloat(args[1]), parseFloat(args[2]), parseFloat(args[3]));
                    Main::player.SetPosition(p);
                }
            }

        }
    }
}