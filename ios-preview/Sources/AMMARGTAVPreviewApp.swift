import SwiftUI
import UniformTypeIdentifiers

// AMMAR YT GTA V — UI-only iPhone/iPad preview.
// This target intentionally DOES NOT contain the GTA V engine or game files.
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

private struct PreviewRoot: View {
    @State private var tab = 0

    var body: some View {
        TabView(selection: $tab) {
            HomeScreen(openData: { tab = 1 })
                .tabItem { Label("الرئيسية", systemImage: "house.fill") }
                .tag(0)
            DataScreen()
                .tabItem { Label("الداتا", systemImage: "square.and.arrow.down") }
                .tag(1)
            ModsScreen()
                .tabItem { Label("المودات", systemImage: "car.side.fill") }
                .tag(2)
            AboutScreen()
                .tabItem { Label("الإعدادات", systemImage: "gearshape.fill") }
                .tag(3)
        }
        .tint(Brand.cyan)
    }
}

private struct HomeScreen: View {
    let openData: () -> Void
    @State private var showPlayNotice = false

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

                    Text("واجهة تجريبية مستقلة للآيفون والآيباد — لا تتضمن المحرك أو بيانات لعبة GTA V.")
                        .font(.subheadline)
                        .foregroundStyle(Brand.muted)
                        .fixedSize(horizontal: false, vertical: true)

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
                                Text("غير مدمج").foregroundStyle(.orange)
                            }
                            HStack {
                                Text("ملفات الداتا")
                                Spacer()
                                Text("غير متوفرة").foregroundStyle(.orange)
                            }
                        }
                    }

                    Button {
                        showPlayNotice = true
                    } label: {
                        Label("تشغيل اللعبة", systemImage: "play.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 17)
                            .foregroundStyle(Brand.navy)
                            .background(Brand.cyan, in: RoundedRectangle(cornerRadius: 18))
                    }
                    .buttonStyle(.plain)

                    Button(action: openData) {
                        Label("إعداد مصدر الداتا", systemImage: "externaldrive.fill.badge.plus")
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
        .alert("نسخة واجهة فقط", isPresented: $showPlayNotice) {
            Button("حسنًا", role: .cancel) {}
        } message: {
            Text("زر التشغيل لن يبدأ GTA V حتى نبني المحرك من ملفات متوافقة ومصرح باستخدامها ونربطه بهذا التطبيق.")
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
                            Text("واجهة تجريبية — v0.2.0")
                            Text("iPhone / iPad • iOS 16+")
                            Text("لا تحتوي هذه النسخة على بيانات اللعبة أو محرك GTA V.")
                                .font(.subheadline)
                                .foregroundStyle(Brand.muted)
                        }
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
