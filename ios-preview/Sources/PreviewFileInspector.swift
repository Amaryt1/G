import Foundation
import CryptoKit

/// Non-destructive, security-scoped inspection for the standalone iOS preview.
///
/// This is NOT a mod installer, a game-data downloader, an archive extractor,
/// or a game-engine compatibility certificate. It never copies or executes data.
struct PreviewFileReport {
    let name: String
    let kind: String
    let size: String
    let detail: String
    let sha256: String?
}

enum PreviewFileInspector {
    private static let smallFileLimit: Int64 = 8 * 1024 * 1024

    static func inspect(_ url: URL) -> PreviewFileReport {
        let accessGranted = url.startAccessingSecurityScopedResource()
        defer {
            if accessGranted { url.stopAccessingSecurityScopedResource() }
        }

        let values = try? url.resourceValues(forKeys: [.isDirectoryKey, .fileSizeKey])
        let isDirectory = values?.isDirectory ?? false
        let name = url.lastPathComponent

        if isDirectory {
            // These are only the minimum structural indicators. The native
            // project's check_game_files.py also checks exact SHA-256 values.
            let required = [
                "data/manifest.json",
                "b/8b0b5899ed/game.wasm",
                "b/8b0b5899ed/shaders/index.json"
            ]
            let available = required.filter {
                FileManager.default.fileExists(atPath: url.appendingPathComponent($0).path)
            }
            let missing = required.filter { !available.contains($0) }
            let detail: String
            if missing.isEmpty {
                detail = "البنية الأساسية للملفات موجودة. هذا فحص أولي فقط؛ لم نفحص بصمات المحرك أو ملفات Shaders كاملة."
            } else {
                detail = "يوجد \(available.count) من 3 ملفات أساسية. المفقود: \(missing.joined(separator: "، "))."
            }
            return PreviewFileReport(
                name: name,
                kind: "مجلد",
                size: "غير محسوب",
                detail: detail,
                sha256: nil
            )
        }

        let bytes = Int64(values?.fileSize ?? 0)
        let extensionName = url.pathExtension.lowercased()
        let kind = extensionName.isEmpty ? "ملف" : extensionName.uppercased()
        let size = ByteCountFormatter.string(fromByteCount: bytes, countStyle: .file)

        guard FileManager.default.isReadableFile(atPath: url.path) else {
            return PreviewFileReport(
                name: name, kind: kind, size: size,
                detail: "لا يمكن قراءة هذا الملف من موقعه الحالي. جرّب نسخه إلى «على الـ iPhone» ثم اختياره.",
                sha256: nil
            )
        }

        // Keep the UI responsive: only small test archives get an inline digest.
        // Large game archives are never loaded or copied into preview storage.
        if bytes > 0 && bytes <= smallFileLimit {
            do {
                let digest = try sha256(for: url)
                return PreviewFileReport(
                    name: name, kind: kind, size: size,
                    detail: "تمت قراءة ملف التجربة وحساب بصمته. لم يُستخرج أو يُثبت أو يُشغّل.",
                    sha256: digest
                )
            } catch {
                return PreviewFileReport(
                    name: name, kind: kind, size: size,
                    detail: "ظهرت مشكلة أثناء القراءة: \(error.localizedDescription)",
                    sha256: nil
                )
            }
        }

        return PreviewFileReport(
            name: name, kind: kind, size: size,
            detail: bytes > smallFileLimit
                ? "تم فحص الاسم والحجم فقط. تُحسب البصمة لاحقًا ضمن نظام التثبيت الحقيقي."
                : "تم التعرف إلى الملف. لم يُستخرج أو يُثبت أو يُشغّل.",
            sha256: nil
        )
    }

    private static func sha256(for url: URL) throws -> String {
        let file = try FileHandle(forReadingFrom: url)
        defer { try? file.close() }
        var hasher = SHA256()
        while let chunk = try file.read(upToCount: 1024 * 1024), !chunk.isEmpty {
            hasher.update(data: chunk)
        }
        return hasher.finalize().map { String(format: "%02x", $0) }.joined()
    }
}
