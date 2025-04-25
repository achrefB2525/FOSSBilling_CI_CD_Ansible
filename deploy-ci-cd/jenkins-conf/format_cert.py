import os

# Script Python pour formater et extraire le certificat
def extract_certificate(input_cert_file):
    try:
        # Récupérer le répertoire d'exécution du script
        script_dir = os.path.dirname(os.path.abspath(__file__))
        
        # Nom du fichier de sortie (même nom que le fichier d'entrée, mais formaté)
        output_cert_file = os.path.join(script_dir, 'formatted_client.crt')
        
        # Ouvrir le fichier contenant le certificat
        with open(input_cert_file, 'r') as infile:
            # Lire tout le contenu du certificat
            cert_data = infile.read()
        
        # Supprimer les lignes BEGIN et END
        start_marker = "-----BEGIN CERTIFICATE-----"
        end_marker = "-----END CERTIFICATE-----"
        
        if start_marker in cert_data and end_marker in cert_data:
            # Extraire la partie du certificat entre les marqueurs
            cert_content = cert_data.split(start_marker)[1].split(end_marker)[0].strip()
            
            # Ajouter 8 espaces avant chaque ligne
            cert_content_with_spaces = '\n'.join(['        ' + line for line in cert_content.splitlines()])
            
            # Écrire le contenu dans un nouveau fichier dans le même répertoire que le script
            with open(output_cert_file, 'w') as outfile:
                outfile.write(cert_content_with_spaces + '\n')
            
            print(f"Le certificat a été formaté et enregistré dans '{output_cert_file}'")
        else:
            print("Le certificat ne contient pas les marqueurs BEGIN/END CERTIFICATE.")

    except Exception as e:
        print(f"Une erreur est survenue : {e}")

# Fichier source du certificat
input_cert_file = '/home/achref/.minikube/profiles/minikube/client.crt'

# Appel de la fonction pour extraire et formater le certificat
extract_certificate(input_cert_file)

