import dropbox
import pandas as pd

# INSERISCI IL TUO ACCESS TOKEN QUI
ACCESS_TOKEN = "" # get access token here https://www.dropbox.com/developers/apps/info/1rwxp6tj84pwc6i#settings 

# Percorso della cartella Dropbox (DEVE iniziare con "/")
DROPBOX_FOLDER = ""  # Modifica con il percorso corretto

# Inizializza il client Dropbox
dbx = dropbox.Dropbox(ACCESS_TOKEN)

def get_shared_link(path):
    """ Ottiene il link condiviso per un file in Dropbox. Se non esiste, lo crea. """
    try:
        shared_links = dbx.sharing_list_shared_links(path).links
        if shared_links:
            return shared_links[0].url.replace("?dl=0", "?raw=1")  # Modifica per visualizzare immagini direttamente
        else:
            shared_link = dbx.sharing_create_shared_link_with_settings(path)
            return shared_link.url.replace("?dl=0", "?raw=1")
    except Exception as e:
        print(f"Errore con il file {path}: {e}")
        return None

def get_all_files():
    """ Recupera tutti i file nella cartella Dropbox """
    file_links = []
    try:
        response = dbx.files_list_folder(DROPBOX_FOLDER)
        while response:
            for entry in response.entries:
                if isinstance(entry, dropbox.files.FileMetadata) and entry.name.lower().endswith((".jpg", ".jpeg")):
                    file_path = entry.path_lower
                    file_link = get_shared_link(file_path)
                    if file_link:
                        file_links.append((entry.name, file_link))
            
            # Controlla se ci sono altre pagine di risultati
            if response.has_more:
                response = dbx.files_list_folder_continue(response.cursor)
            else:
                break

    except Exception as e:
        print(f"Errore durante l'accesso a Dropbox: {e}")

    return file_links

# Esegui e salva in un CSV
files = get_all_files()
df = pd.DataFrame(files, columns=["filename", "dropbox_url"])
df.to_csv("dropbox_links.csv", index=False)

print("✅ Link generati e salvati in dropbox_links.csv!")

