#include "help.as"
#include "tp.as"

namespace Commands {
    funcdef void OnCommandSent(array<string>@ args, player p);

    dictionary commands;

    void Init() {
        commands["help"] = @Help::OnCommandSent;
        commands["tp"] = @Teleport::OnCommandSent;
    }

    void ExecuteCommand(string command, player p) {
        array<string>@ args = command.split(" ");

        if(commands.exists(args[0])) {
            cast<OnCommandSent@>(commands[args[0]])(@args, p);
        }
    }
}