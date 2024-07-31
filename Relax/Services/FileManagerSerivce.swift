//
//  FileManagerSerivce.swift
//  Relax
//
//  Created by Илья Кузнецов on 31.07.2024.
//

import Foundation

protocol IFileManagerSerivce: AnyObject {
    func getDownloadFiles() -> [FileItem]
    func getContentsOfFolder(at url: URL) -> [FileItem] 
    func deleteFile(at url: URL) -> Bool
}

struct FileItem: Identifiable {
    let id = UUID()
    let url: URL
}

final class FileManagerSerivce: IFileManagerSerivce {
    
    let fileManager = FileManager.default
    
    func getDownloadFiles() -> [FileItem] {
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: nil)
            let folderURLs = fileURLs.filter { url in
                var isDir: ObjCBool = false
                fileManager.fileExists(atPath: url.path, isDirectory: &isDir)
                return isDir.boolValue
            }
            return folderURLs.map { FileItem(url: $0) }
        } catch {
            print("Ошибка при получении скачанных файлов из файлового менеджера")
            return []
        }
    }
    
    func getContentsOfFolder(at url: URL) -> [FileItem] {
        
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
            return fileURLs.map { FileItem(url: $0) }
        } catch {
            print("Error while enumerating files: \(error.localizedDescription)")
            return []
        }
    }
    
    func deleteFile(at url: URL) -> Bool {
            do {
                try fileManager.removeItem(at: url)
                print("Файл успешно удален: \(url)")
                return true
            } catch {
                print("Ошибка при удалении файла: \(error.localizedDescription)")
                return false
            }
        }
    
}
