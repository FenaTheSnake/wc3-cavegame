namespace MPTest {
    bool ishost;
    int c = 0;
    trigger recieve;

    void Send() {
        if(!ishost) return;
        __debug(c + " sending");

        string data;
        for(int i = 0; i < 512; i++) {
            data += "a";
        }
        SendSyncData("test", data);
        c += 1;
    }

    void Recieve() {
        if(ishost) return;
        __debug(c + " recieve " + GetTriggerSyncData());
        c += 1;
    }

    void Start() {
        ishost = GetHostPlayer() == GetLocalPlayer();

        recieve = CreateTrigger();
        for(int i = 0; i < 12; i++) {
            TriggerRegisterPlayerSyncEvent(recieve, Player(i), "test", true);
        }
        TriggerAddAction(recieve, @Recieve);

        TimerStart(CreateTimer(), 0.25f, true, @Send);
    }
}