namespace Save {

    // represents a file with chunks data
    class ChunkFile {
        array<string> data;
        textfilehandle file;

        // used when saving in process
        bool isRead;        // keep tracking is file was read and modified

        ChunkFile() {}
    }

    // a collection of text files with saved information about the world
    class WorldSave {
        string name;
        string pathRoot;
        
        textfilehandle worldFile;       // main world data
        array<ChunkFile@> chunksFiles;  // saved chunks
        uint lastSavedChunk = 0;
        uint lastCreatedFile = 0;

        dictionary savedChunks;     // contains [ChunkPos: uint], where uint is file number(0-15bits) and line number(16-31bits)

        WorldSave() {}
        ~WorldSave() {
            for(int i = 0; i < chunksFiles.length(); i++) {
                if(chunksFiles[i] != null){
                    TextFileClose(chunksFiles[i].file);
                }
            }
            
            if(worldFile != nil) {
                TextFileClose(worldFile);
            }
        }

        void CreateNewChunksFile() {
            lastCreatedFile += 1;
            ChunkFile f = ChunkFile();
            f.file = TextFileOpen(pathRoot + PATH_CHUNKS_FILE + "-" + lastCreatedFile + SAVE_EXTENSION);
            chunksFiles.insertLast(@f);

            __debug("created new file, lastCreatedFile = " + lastCreatedFile);
        }

        void BeginSaving() {
            __debug_section_start("Save " + name);
            for(int i = 0; i < lastCreatedFile; i++) {
                chunksFiles[i].isRead = false;
            }
        }

        // save chunk
        void AddChunk(World::Chunk@ chunk) {
            // if this chunk belongs to a file that is not created yet
            while(UINTID2ChunkFileID(lastSavedChunk) >= lastCreatedFile) {
                CreateNewChunksFile();
            }

            ChunkFile@ f = chunksFiles[UINTID2ChunkFileID(lastSavedChunk)];
            if(f == null) {
                __debug("file is null, aborting");
                return;
            }
            if(!f.isRead) {
                f.data = TextFileReadAllLines(f.file).split("\n");
                f.data.resize(SAVE_CHUNK_MAX_AMOUNT);
                f.isRead = true;
            }

            f.data[UINTID2ChunkID(lastSavedChunk)] = chunk.Serialize();
            savedChunks[chunk.position] = lastSavedChunk;
            
            lastSavedChunk += 1;
        }

        void FinishSaving() {
            for(int i = 0; i < lastCreatedFile; i++) {
                if(chunksFiles[i].isRead) {
                    TextFileClear(chunksFiles[i].file);
                    auto d = join(chunksFiles[i].data, "\n");
                    TextFileWriteLine(chunksFiles[i].file, d);

                }
            }

            TextFileClear(worldFile);

            TextFileWriteLine(worldFile, "name: " + name);
            TextFileWriteLine(worldFile, "chunks: " + lastSavedChunk);
            TextFileWriteLine(worldFile, "files: " + lastCreatedFile);

            __debug_section_end();
        }

        bool IsChunkSaved(const World::ChunkPos &in pos) {
            return savedChunks.exists(pos);
        }

        World::Chunk@ LoadChunk(const World::ChunkPos &in pos, World::WorldInstance@ &in world) {
            if(!IsChunkSaved(pos)) return null;

            World::Chunk@ chunk = @Memory::chunkPool.GetChunk();

            uint id = uint(savedChunks[pos]);
            string data = TextFileReadLine(chunksFiles[UINTID2ChunkFileID(id)].file, UINTID2ChunkID(id));

            chunk.Deserialize(data);
            chunk.on_map_position = World::ChunkPosToWC3Position(chunk.position);
            @chunk.world = @world;

            chunk.generationState = World::ChunkGenerationState::GENERATED;
            return @chunk;
        }

        // loads all data from worldFile and chunkFiles, worldFile should be already open and initialized
        void Load() {
            __debug_section_start("Loading world");
            name = TextFileReadLine(worldFile, 0).split(": ")[1];
            lastSavedChunk = parseInt(TextFileReadLine(worldFile, 1).split(": ")[1]);
            lastCreatedFile = parseInt(TextFileReadLine(worldFile, 2).split(": ")[1]);

            int loadedChunks = 0;
            for(int i = 0; i < lastCreatedFile; i++) {
                ChunkFile f = ChunkFile();
                f.file = TextFileOpen(pathRoot + PATH_CHUNKS_FILE + "-" + (i+1) + SAVE_EXTENSION);
                chunksFiles.insertLast(@f);
                __debug("loading chunkfile " + (i+1));

                string datas = TextFileReadAllLines(chunksFiles[i].file);
                array<string>@ data = datas.split("\n");
                for(int j = 0; j < data.length(); j++) {
                    if(data[j].isEmpty()) {
                        j = data.length();
                        continue;
                    }
                    array<string>@ ss = data[j].split("|");
                    savedChunks[World::ChunkPos(parseInt(ss[0]), parseInt(ss[1]), parseInt(ss[2]))] = loadedChunks++;
                }
            }

            if(loadedChunks != lastSavedChunk) {
                __debug("loaded less chunks than expected. Some data might been missing.");
                __debug("loaded chunks: " + loadedChunks + "\nlastSavedChunk from worldFile: " + lastSavedChunk);
            }

            __debug_section_end();
        } 
    }

    WorldSave@ CreateWorldSave(string name) {
        if(TextFileExists(PATH_SAVES + name + "\\" + PATH_WORLD_FILE + SAVE_EXTENSION)) {
            return null;
        }

        WorldSave worldSave = WorldSave();
        worldSave.name = name;
        worldSave.pathRoot = PATH_SAVES + name + "\\";
        worldSave.worldFile = TextFileOpen(worldSave.pathRoot + PATH_WORLD_FILE + SAVE_EXTENSION);

        __debug("WorldSave \"" + name + "\" created.");
        return @worldSave;
    }

    WorldSave@ OpenWorldSave(string name) {
        if(!TextFileExists(PATH_SAVES + name + "\\" + PATH_WORLD_FILE + SAVE_EXTENSION)) {
            return null;
        }

        WorldSave worldSave = WorldSave();
        worldSave.pathRoot = PATH_SAVES + name + "\\";
        worldSave.worldFile = TextFileOpen(worldSave.pathRoot + PATH_WORLD_FILE + SAVE_EXTENSION);

        worldSave.Load();

        //__debug("Loading existing world is not implemented yet.");

        __debug("WorldSave \"" + name + "\" open.");
        return @worldSave;
    }

    WorldSave@ CreateOrOpenWorldSave(string name) {
        WorldSave@ worldSave = OpenWorldSave(name);
        if(worldSave != null) return @worldSave;
        return @CreateWorldSave(name);
    }
}