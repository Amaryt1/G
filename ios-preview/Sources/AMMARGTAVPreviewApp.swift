import SwiftUI
import UniformTypeIdentifiers
import CryptoKit

// Shared AMMAR YT launcher. The preview compiles without GTA V; native engine
// builds compile the same screen with AMMAR_NATIVE and their own AppDelegate.
#if !AMMAR_NATIVE
@main
struct AMMARGTAVPreviewApp: App {
    var body: some Scene {
        WindowGroup {
            PreviewRoot()
                .preferredColorScheme(.dark)
                .environment(\.layoutDirection, .rightToLeft)
        }
    }
}
#endif

enum AMMARBuild {
    // The preview Xcode project is generated locally and can keep stale build
    // settings after a GitHub Pull. This constant updates the visible version
    // immediately; bump it with every visible change.
    static let version = "0.3.1"
}

// Actions are only connected to a real engine in the native Xcode target.
// Preview mode has no engine and deliberately cannot fake a successful launch.
final class AMMARLauncherBridge: ObservableObject {
    @Published var nativeAvailable = false
    @Published var dataReady = false
    @Published var dataBusy = false
    @Published var launching = false
    @Published var selectedMode = 0 // 0 = Story; 1 = Sandbox
    var onPlay: ((Int) -> Void)?
    var onData: (() -> Void)?
    var onMods: (() -> Void)?
    var onSettings: (() -> Void)?
}

private enum Brand {
    static let navy = Color(red: 0.025, green: 0.055, blue: 0.105)
    static let panel = Color(red: 0.075, green: 0.125, blue: 0.205)
    static let cyan = Color(red: 0.20, green: 0.85, blue: 0.98)
    static let muted = Color(red: 0.62, green: 0.71, blue: 0.82)
}

private struct PreviewBackground<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Brand.navy, Color(red: 0.08, green: 0.12, blue: 0.23), Brand.navy],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            content
        }
        .foregroundStyle(.white)
    }
}

private struct PreviewPanel<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Brand.panel.opacity(0.94), in: RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(.white.opacity(0.09), lineWidth: 1)
            )
    }
}

struct PreviewRoot: View {
    @ObservedObject var bridge: AMMARLauncherBridge
    @State private var tab = 0

    init(bridge: AMMARLauncherBridge = AMMARLauncherBridge()) {
        self.bridge = bridge
    }

    var body: some View {
        TabView(selection: $tab) {
            HomeScreen(bridge: bridge, openData: { tab = 1 })
                .tabItem { Label("الرئيسية", systemImage: "house.fill") }
                .tag(0)

            Group {
                if bridge.nativeAvailable {
                    NativeGatewayScreen(
                        title: "إدارة الداتا",
                        icon: "externaldrive.fill.badge.plus",
                        explanation: "افتح مدير ملفات اللعبة الحقيقي لاستيراد الداتا أو تحميل أرشيف متوافق من مصدر مصرح به.",
                        buttonTitle: "فتح مدير الداتا",
                        action: { bridge.onData?() })
                } else {
                    DataScreen()
                }
            }
            .tabItem { Label("الداتا", systemImage: "square.and.arrow.down") }
            .tag(1)

            Group {
                if bridge.nativeAvailable {
                    NativeGatewayScreen(
                        title: "المودات والسيارات",
                        icon: "car.side.fill",
                        explanation: "إدارة المودات الحقيقية، بما يشمل الاستيراد والتفعيل والتعطيل ضمن أنواع الملفات التي يدعمها المحرك.",
                        buttonTitle: "فتح مدير المودات",
                        action: { bridge.onMods?() })
                } else {
                    ModsScreen()
                }
            }
            .tabItem { Label("المودات", systemImage: "car.side.fill") }
            .tag(2)

            AboutScreen(bridge: bridge)
                .tabItem { Label("الإعدادات", systemImage: "gearshape.fill") }
                .tag(3)
        }
        .tint(Brand.cyan)
    }
}

private struct HomeScreen: View {
    @ObservedObject var bridge: AMMARLauncherBridge
    let openData: () -> Void

    var body: some View {
        PreviewBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    HStack(spacing: 12) {
                        Image(systemName: "gamecontroller.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(Brand.cyan)
                            .frame(width: 54, height: 54)
                            .background(Brand.cyan.opacity(0.13), in: RoundedRectangle(cornerRadius: 16))
                        VStack(alignment: .leading, spacing: 4) {
                            Text("AMMAR YT")
                                .font(.system(size: 29, weight: .black, design: .rounded))
                            Text("GTA V")
                                .font(.system(size: 22, weight: .heavy, design: .rounded))
                                .foregroundStyle(Brand.cyan)
                        }
                        Spacer()
                    }

                    Text("نسختك الخاصة. تجربة جديدة.")
                        .font(.title3.bold())

                    Text(bridge.nativeAvailable
                         ? "واجهة اللعبة الأصلية: اختر وضع اللعب، واضبط الداتا، ثم ابدأ التشغيل."
                         : "واجهة تجريبية مستقلة للآيفون والآيباد — لا تتضمن المحرك أو بيانات لعبة GTA V.")
                        .font(.subheadline)
                        .foregroundStyle(Brand.muted)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack {
                        Text("إصدار التطبيق")
                        Spacer()
                        Text("v\(AMMARBuild.version)")
                            .font(.caption.bold().monospacedDigit())
                            .foregroundStyle(Brand.cyan)
                    }
                    .font(.footnote)
                    .foregroundStyle(Brand.muted)

                    PreviewPanel {
                        VStack(alignment: .leading, spacing: 14) {
                            Label("حالة النسخة", systemImage: "checkmark.shield.fill")
                                .font(.headline)
                                .foregroundStyle(Brand.cyan)
                            HStack {
                                Text("الواجهة")
                                Spacer()
                                Text("جاهزة للتجربة").foregroundStyle(.green)
                            }
                            HStack {
                                Text("محرك اللعبة")
                                Spacer()
                                Text(bridge.nativeAvailable ? "متصل بالتطبيق" : "غير مدمج")
                                    .foregroundStyle(bridge.nativeAvailable ? .green : .orange)
                            }
                            HStack {
                                Text("ملفات الداتا")
                                Spacer()
                                Text(bridge.dataReady ? "تم تحديد المصدر" : "غير متوفرة")
                                    .foregroundStyle(bridge.dataReady ? .green : .orange)
                            }
                        }
                    }

                    PreviewPanel {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("وضع اللعب").font(.headline)
                            Picker("وضع اللعب", selection: $bridge.selectedMode) {
                                Text("القصة").tag(0)
                                Text("التجوال الحر").tag(1)
                            }
                            .pickerStyle(.segmented)
                        }
                    }

                    Button {
                        if bridge.nativeAvailable {
                            bridge.onPlay?(bridge.selectedMode)
                        } else {
                            // A UI preview cannot open a native GTA engine it does not contain.
                            // Navigate directly to the available data setup without a fake
                            // "game launched" alert.
                            openData()
                        }
                    } label: {
                        Label(
                            bridge.nativeAvailable
                                ? (bridge.launching ? "جارٍ تشغيل اللعبة…" : "تشغيل اللعبة")
                                : "فتح إعدادات اللعبة",
                            systemImage: bridge.nativeAvailable ? "play.fill" : "externaldrive.fill"
                        )
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 17)
                            .foregroundStyle(Brand.navy)
                            .background(Brand.cyan, in: RoundedRectangle(cornerRadius: 18))
                    }
                    .buttonStyle(.plain)
                    .disabled(bridge.launching)

                    Button(action: openData) {
                        Label("إدارة رابط الداتا", systemImage: "externaldrive.fill.badge.plus")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .foregroundStyle(.white)
                            .background(.white.opacity(0.09), in: RoundedRectangle(cornerRadius: 18))
                    }
                    .buttonStyle(.plain)

                    PreviewPanel {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("خطتنا القادمة", systemImage: "list.bullet.rectangle")
                                .font(.headline)
                            Text("ربط الواجهة بالمحرك، ثم اختبار إدارة الداتا والمودات والسيارات على الأجهزة الحقيقية.")
                                .font(.subheadline)
                                .foregroundStyle(Brand.muted)
                        }
                    }
                }
                .padding(20)
            }
        }
    }
}

private struct DataScreen: View {
    @AppStorage("authorizedDataSourceURL") private var savedURL = ""
    @State private var draftURL = ""
    @State private var selectedFileReport: PreviewFileReport?
    @State private var showingImporter = false
    @State private var showingAlert = false
    @State private var alertMessage = ""

    var body: some View {
        PreviewBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("إدارة الداتا")
                        .font(.largeTitle.bold())
                    Text("احفظ رابطًا مصرحًا به وافحص أرشيفًا أو مجلد ملفات محليًا. هذه المعاينة لا تنزّل ولا تستخرج الداتا.")
                        .font(.subheadline)
                        .foregroundStyle(Brand.muted)

                    PreviewPanel {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("رابط مصدر الداتا", systemImage: "link")
                                .font(.headline)
                                .foregroundStyle(Brand.cyan)
                            TextField("https://example.com/game-data.zip", text: $draftURL)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .keyboardType(.URL)
                                .submitLabel(.done)
                                .padding(12)
                                .background(.black.opacity(0.25), in: RoundedRectangle(cornerRadius: 12))
                                .environment(\.layoutDirection, .leftToRight)
                            Button("حفظ الرابط على هذا الجهاز") {
                                saveURL()
                            }
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .foregroundStyle(Brand.navy)
                            .background(Brand.cyan, in: RoundedRectangle(cornerRadius: 13))
                        }
                    }

                    PreviewPanel {
                        VStack(alignment: .leading, spacing: 10) {
                            Label("الرابط المحفوظ", systemImage: "checkmark.circle")
                                .font(.headline)
                            Text(savedURL.isEmpty ? "لا يوجد رابط محفوظ" : savedURL)
                                .font(.footnote.monospaced())
                                .foregroundStyle(Brand.muted)
                                .textSelection(.enabled)
                        }
                    }

                    PreviewPanel {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("استعراض الملفات المحلية", systemImage: "folder")
                                .font(.headline)
                            Button {
                                showingImporter = true
                            } label: {
                                Label("اختيار أرشيف أو مجلد", systemImage: "doc.badge.plus")
                            }
                            .tint(Brand.cyan)

                            if let report = selectedFileReport {
                                FileReportCard(report: report)
                            } else {
                                Text("لم تختر ملفًا بعد")
                                    .font(.subheadline)
                                    .foregroundStyle(Brand.muted)
                            }
                            Text("الفحص لا ينسخ أي بيانات، ولا يثبت أرشيف اللعبة أو المودات.")
                                .font(.caption)
                                .foregroundStyle(Brand.muted)
                        }
                    }
                }
                .padding(20)
            }
        }
        .onAppear { draftURL = savedURL }
        .fileImporter(
            isPresented: $showingImporter,
            allowedContentTypes: [.zip, .archive, .folder],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first { selectedFileReport = PreviewFileInspector.inspect(url) }
            case .failure(let error):
                alertMessage = "لم يُفتح الملف: \(error.localizedDescription)"
                showingAlert = true
            }
        }
        .alert("مدير الداتا", isPresented: $showingAlert) {
            Button("حسنًا", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }

    private func saveURL() {
        let value = draftURL.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let parts = URLComponents(string: value),
              parts.scheme?.lowercased() == "https",
              let host = parts.host, !host.isEmpty,
              parts.user == nil, parts.password == nil else {
            alertMessage = "اكتب رابط HTTPS صالحًا بدون اسم مستخدم أو كلمة مرور."
            showingAlert = true
            return
        }
        savedURL = value
        alertMessage = "تم حفظ الرابط محليًا للتجربة. لم يبدأ أي تنزيل، وسنضيف فحص التوافق والسلامة عند ربط محرك اللعبة."
        showingAlert = true
    }
}

private struct ModsScreen: View {
    @State private var showingModImporter = false
    @State private var selectedModReport: PreviewFileReport?
    @State private var modImportError = ""

    var body: some View {
        PreviewBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("المودات والسيارات")
                        .font(.largeTitle.bold())
                    Text("تصميم مبدئي للأقسام التي سنربطها بنظام المودات بعد اختبار محرك اللعبة.")
                        .font(.subheadline)
                        .foregroundStyle(Brand.muted)
                    feature("سيارات مخصصة", symbol: "car.side.fill", description: "تثبيت سيارات Replacement وAdd-on بعد التحقق من التوافق")
                    feature("الشخصيات", symbol: "person.crop.square", description: "إدارة نماذج الشخصيات والملابس المدعومة")
                    feature("AMMAR MOD MENU", symbol: "slider.horizontal.3", description: "خيارات اللعب والغش التي يدعمها المحرك فعليًا")
                    feature("الوضع الآمن", symbol: "shield.lefthalf.filled", description: "تشغيل اللعبة بدون مودات عند وقوع مشكلة")
                    PreviewPanel {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("فحص ملف مود محلي", systemImage: "doc.zipper")
                                .font(.headline)
                                .foregroundStyle(Brand.cyan)
                            Button {
                                showingModImporter = true
                            } label: {
                                Label("اختيار ZIP / OIV / ملف مود", systemImage: "square.and.arrow.down")
                            }
                            .tint(Brand.cyan)
                            if let report = selectedModReport {
                                FileReportCard(report: report)
                            } else {
                                Text("يمكن اختيار ملف تجريبي وعرض حجمه وبصمته عند صغر حجمه.")
                                    .font(.subheadline)
                                    .foregroundStyle(Brand.muted)
                            }
                            if !modImportError.isEmpty {
                                Text(modImportError)
                                    .font(.footnote)
                                    .foregroundStyle(.orange)
                            }
                            Text("الفحص فقط: لن تُثبت المودات أو تُنفّذ داخل اللعبة.")
                                .font(.caption)
                                .foregroundStyle(Brand.muted)
                        }
                    }
                }
                .padding(20)
            }
        }
        .fileImporter(
            isPresented: $showingModImporter,
            allowedContentTypes: [.zip, .archive, .data],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    selectedModReport = PreviewFileInspector.inspect(url)
                    modImportError = ""
                }
            case .failure(let error):
                modImportError = "فشل فتح الملف: \(error.localizedDescription)"
            }
        }
    }

    private func feature(_ title: String, symbol: String, description: String) -> some View {
        PreviewPanel {
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: symbol)
                    .font(.title2)
                    .foregroundStyle(Brand.cyan)
                    .frame(width: 34)
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(title).font(.headline)
                        Spacer()
                        Text("قريبًا")
                            .font(.caption.bold())
                            .foregroundStyle(Brand.muted)
                    }
                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(Brand.muted)
                }
            }
        }
    }
}

private struct AboutScreen: View {
    @ObservedObject var bridge: AMMARLauncherBridge

    var body: some View {
        PreviewBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("الإعدادات")
                        .font(.largeTitle.bold())
                    PreviewPanel {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("AMMAR YT GTA V", systemImage: "gamecontroller")
                                .font(.title3.bold())
                                .foregroundStyle(Brand.cyan)
                            Text(bridge.nativeAvailable ? "نسخة المحرك — v\(AMMARBuild.version)" : "واجهة تجريبية — v\(AMMARBuild.version)")
                            Text("iPhone / iPad • iOS 16+")
                            Text(bridge.nativeAvailable
                                 ? "تطبيق المحرك الأصلي. تحتاج إلى بيانات لعبة متوافقة قبل التشغيل."
                                 : "لا تحتوي هذه النسخة على بيانات اللعبة أو محرك GTA V.")
                                .font(.subheadline)
                                .foregroundStyle(Brand.muted)
                        }
                    }
                    if bridge.nativeAvailable {
                        Button {
                            bridge.onSettings?()
                        } label: {
                            Label("فتح الإعدادات الحقيقية", systemImage: "gearshape.fill")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .foregroundStyle(Brand.navy)
                                .background(Brand.cyan, in: RoundedRectangle(cornerRadius: 18))
                        }
                        .buttonStyle(.plain)
                    }
                    PreviewPanel {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("الخصوصية", systemImage: "lock.shield")
                                .font(.headline)
                            Text("لا تجمع هذه المعاينة إحصائيات ولا تتصل بخدمات المطور الأصلي. رابط الداتا محفوظ محليًا، وفحص الملفات لا يرسل محتوياتها إلى أي خادم.")
                                .font(.subheadline)
                                .foregroundStyle(Brand.muted)
                        }
                    }
                    PreviewPanel {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("حقوق الاستخدام", systemImage: "info.circle")
                                .font(.headline)
                            Text("هذه واجهة مستقلة للتجربة وليست نسخة من لعبة GTA V. حقوق اللعبة وعلامتها تعود لأصحابها؛ لا توزّع بيانات أو محركات محمية دون تصريح.")
                                .font(.subheadline)
                                .foregroundStyle(Brand.muted)
                        }
                    }
                }
                .padding(20)
            }
        }
    }
}


// Shared detail card for non-destructive file inspection.
private struct FileReportCard: View {
    let report: PreviewFileReport

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Label(report.name, systemImage: "doc.text.magnifyingglass")
                .font(.subheadline.bold())
                .lineLimit(2)
            HStack {
                Text("النوع: \(report.kind)")
                Spacer()
                Text(report.size)
            }
            .font(.caption)
            .foregroundStyle(Brand.muted)
            Text(report.detail)
                .font(.caption)
                .foregroundStyle(Brand.muted)
                .fixedSize(horizontal: false, vertical: true)
            if let digest = report.sha256 {
                Text("SHA-256: \(digest)")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(Brand.cyan)
                    .textSelection(.enabled)
                    .environment(\.layoutDirection, .leftToRight)
            }
        }
    }
}

// Embedded helper: the generated Xcode project can build without refreshing its file references.
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



// Reuses the exact preview design in the real native game without showing
// misleading preview-only URL forms or fake mod installation controls.
private struct NativeGatewayScreen: View {
    let title: String
    let icon: String
    let explanation: String
    let buttonTitle: String
    let action: () -> Void

    var body: some View {
        PreviewBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text(title).font(.largeTitle.bold())
                    PreviewPanel {
                        VStack(alignment: .leading, spacing: 14) {
                            Label(title, systemImage: icon)
                                .font(.headline)
                                .foregroundStyle(Brand.cyan)
                            Text(explanation)
                                .font(.subheadline)
                                .foregroundStyle(Brand.muted)
                            Button(action: action) {
                                Label(buttonTitle, systemImage: "arrow.up.right.square")
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 15)
                                    .foregroundStyle(Brand.navy)
                                    .background(Brand.cyan, in: RoundedRectangle(cornerRadius: 15))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    Text("تستخدم هذه الشاشة مدير البيانات أو المودات الفعلي الموجود في مشروع المحرك.")
                        .font(.caption)
                        .foregroundStyle(Brand.muted)
                }
                .padding(20)
            }
        }
    }
}
