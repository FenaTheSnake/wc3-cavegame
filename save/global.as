namespace Save {
    namespace Global {
        textfilehandle worldList = nil;
        textfilehandle chunkFileHandle = nil;

        array<string>@ GetWorldList() {
            if(worldList == nil) {
                worldList = TextFileOpen(PATH_MAP_ROOT + PATH_GLOBAL_WORLD_LIST_FILE + SAVE_EXTENSION);
            }
            string data = TextFileReadAllLines(worldList);
            array<string>@ names = @data.split("\n");
            for(int i = 0; i < names.length(); i++) {
                if(names[i].isEmpty()) names.removeAt(i--);
            }

            TextFileClose(worldList);
            worldList = nil;
            return @names;
        }

        void AddWorldToList(string name) {
            array<string>@ worlds = GetWorldList();
            worldList = TextFileOpen(PATH_MAP_ROOT + PATH_GLOBAL_WORLD_LIST_FILE + SAVE_EXTENSION);
            if(worlds.find(name) < 0) {
                worlds.insertLast(name);

                TextFileClear(worldList);
                TextFileWriteLine(worldList, join(worlds, "\n"));
            }

            TextFileClose(worldList);
            worldList = nil;
        }

        void OpenChunkFile(string path) {
            if(chunkFileHandle != nil) TextFileClose(chunkFileHandle);
            chunkFileHandle = TextFileOpen(path);
        }
    }
}