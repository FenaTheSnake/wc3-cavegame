namespace Save {
    namespace Global {
        textfilehandle worldList;

        array<string>@ GetWorldList() {
            if(worldList == nil) {
                worldList = TextFileOpen(PATH_MAP_ROOT + PATH_GLOBAL_WORLD_LIST + SAVE_EXTENSION);
            }
            string data = TextFileReadAllLines(worldList);

            array<string>@ names = @data.split("\n");
            for(int i = 0; i < names.length(); i++) {
                if(names[i].isEmpty()) names.removeAt(i--);
            }

            return @names;
        }

        void AddWorldToList(string name) {
            array<string>@ worlds = GetWorldList();
            if(worlds.find(name) < 0) {
                worlds.insertLast(name);

                TextFileClear(worldList);
                TextFileWriteLine(worldList, join(worlds, "\n"));
            }
        }
    }
}