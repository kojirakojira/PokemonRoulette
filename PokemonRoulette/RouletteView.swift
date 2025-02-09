import SwiftUI
// リールの状態: リールの数だけ好きな場所に持って置く
let realState = RealState()

struct RouletteView: View {
    @Binding var pokemonArr: [Pokemon]
    @State var dispArr: [Pokemon] = []
    @State var realController: RealController!
    
    @State private var isStop: Bool = true
    @State var isDisabled: Bool = false
    @State private var btnText: String = "Start"
    
    @State private var openDetailView: Bool = false
    @State private var selectedPid: String = ""
    @State private var willDraw: Bool = false
    
    @State private var toastQueue = ToastQueue()
    
    var body: some View {
        
        NavigationStack {
            ZStack {
                VStack {
                    Spacer()
                    // サンプルではリールは1個だけ
                    ReelView(dispArr: $dispArr)
                    Spacer()
                    // ルーレットスタート/ストップボタン
                    Button {
                        if (isStop) {
                            realController.start()
                            btnText = "Stop"
                            isStop = false
                        } else {
                            realController.stop()
                            btnText = "Start"
                            isStop = true
                        }
                    } label: {
                        Text(btnText)
                            .frame(width: UIScreen.main.bounds.width / 2)
                            .padding()
                            .font(Font.largeTitle)
                            .background(isDisabled ? Color.gray : Color.orange)
                            .foregroundStyle(.black)
                            .cornerRadius(10)
                    }
                    .disabled(isDisabled)
                    .sheet(isPresented: $openDetailView) {
                        RouletteResultView(
                            openDetailView: $openDetailView,
                            willDraw: $willDraw,
                            pokedexId: selectedPid,
                            name: pokemonArr.filter { $0.pokedexId == selectedPid }
                                .first!.name
                        )
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black)
                .onAppear {
                    // 画面が描画されて初期化が済んでから実行
                    pokemonArr.shuffle()
                    dispArr = createDispArr(pokemonArr)
                    realState.index = Const.pendSize
                    realController = RealController(dispArr: dispArr, isDisabled: $isDisabled, selected: $selectedPid, openDetailView: $openDetailView)
                }
                .onChange(of: openDetailView) { oldValue, newValue in
                    
                    if (!newValue) {
                        var toastTitle: String
                        var toastContent: String
                        if (willDraw) {
                            toastTitle = "「はい」が選択されました。"
                            let name = pokemonArr.filter { $0.pokedexId == selectedPid }
                                .first!.name
                            toastContent = "\(name)(\(selectedPid))を描いてください。"
                        } else {
                            toastTitle = "「いいえ」が選択されました。"
                            toastContent = "いや、描けよ"
                        }
                        
                        selectedPid = ""
                        willDraw = false
                        
                        toastQueue.append(.elem(toastTitle, toastContent))
                    }
                }
                Toast(toastQueue: toastQueue)
            }
        }
    }
    
    private func createDispArr(_ pokemonArr: [Pokemon]) -> [Pokemon] {
        
        var dispArr: [Pokemon] = []
        
        dispArr.append(contentsOf: createSuffixArr(pokemonArr))
        dispArr.append(contentsOf: pokemonArr)
        dispArr.append(contentsOf: createPrefixArr(pokemonArr))
        
        return dispArr
        
    }
    
    private func createSuffixArr(_ arr: [Pokemon]) -> [Pokemon] {
        var retArr: [Pokemon]
        if (arr.count < Const.pendSize) {
            retArr = []
            let size = arr.count
            let reverseArr: [Pokemon] = arr.reversed()
            for i in 0..<Const.pendSize {
                // size=3の場合、2,1,0,2のループになる
                let p: Pokemon = reverseArr[i % size]
                retArr.append(Pokemon(p.pokedexId, p.name, p.didDraw))
            }
            retArr = retArr.reversed()
        } else {
            retArr = arr.suffix(Const.pendSize).map({ p in
                return Pokemon(p.pokedexId, p.name, p.didDraw)
            })
        }
        return retArr
    }
    
    private func createPrefixArr(_ arr: [Pokemon]) -> [Pokemon] {
        var retArr: [Pokemon]
        if (arr.count < Const.pendSize) {
            // 要素数がprefixCountより少ない場合
            retArr = []
            let size = arr.count
            for i in 0..<Const.pendSize {
                // size=3の場合、0,1,2,0,1,2のループになる
                let p: Pokemon = arr[i % size]
                retArr.append(Pokemon(p.pokedexId, p.name, p.didDraw))
            }
        } else {
            retArr = Array(arr.prefix(Const.pendSize)).map({ p in
                return Pokemon(p.pokedexId, p.name, p.didDraw)
            })
        }
        return retArr
    }
}

enum Const {
    //  配列の前後に追加するリストの数（ルーレットの描画上の考慮）
    static let pendSize: Int = 4
    static let width: CGFloat = UIScreen.main.bounds.width * 2 / 3
    static let height: CGFloat = 60
    static let scrollViewHeight: CGFloat = height * 6
    // ScrollViewのY軸方向のoffsetの基準は表示エリアの上端。リストの1要素目を中心に持っていったoffsetをベースとする。
    static let baseOffset: CGFloat = (scrollViewHeight - height) / 2
    
    static func calcOffset(index: Int) -> CGFloat {
        return baseOffset - height * CGFloat(index)
    }
}

class RealState: ObservableObject {
    // UIと紐付けたいので @Published
    // pokemonArrの1要素目が中央にくる位置を開始オフセットとする。
    @Published var offset: CGFloat = Const.calcOffset(index: Const.pendSize)
    var index: Int = 0
    var stopIndex: Int! = nil
}

class RealController {
    var dispArr: [Pokemon]
    var isDisabled: Binding<Bool>
    var startIdx: Int
    var endIdx: Int
    
    var selected: Binding<String>
    var openDetailView: Binding<Bool>
    
    // はやく回転するときのスピード
    let reelDurationFast: Double = 0.1
    // ゆっくり回転するときのスピード
    let reelDurationSlow: Double = 0.3
    
    init(dispArr: Array<Pokemon>, isDisabled: Binding<Bool>, selected: Binding<String>, openDetailView: Binding<Bool>) {
        self.dispArr = dispArr
        self.isDisabled = isDisabled
        self.selected = selected
        self.openDetailView = openDetailView
        
        self.startIdx = Const.pendSize
        self.endIdx = dispArr.count - Const.pendSize - 1
    }
    
    func start() {
        realState.stopIndex = nil
        loop()
    }
    
    func stop() {
        let nowIdx = realState.index - startIdx
        let arrSize = endIdx + 1 - startIdx
        var arr: [Int] = []
        for i in 3...8 {
            arr.append((nowIdx + i) % arrSize)
        }
        
        let rand = Int.random(in: 0...arr.count - 1)
        realState.stopIndex = arr[rand] + startIdx
        // ボタンを押してから止まるまでの間はボタンを非活性にする。（この参照の仕方はアンチパターン？）
        self.isDisabled.wrappedValue = true
        print("stopIndex: \(String(describing: realState.stopIndex))")
    }
    
    func loop() {
        spinOne() {
            if (self.canStop()) {
                self.didStop()
            } else {
                // 再帰呼び出し
                self.loop()
            }
        }
    }
    
    private func spinOne(completion: @escaping () -> Void) {
        let oldIndex = realState.index // 現在の index を取得
        var newIndex = oldIndex + 1
        
        if (newIndex > endIdx) {
            // pokemonArrの要素数を超えた場合は、配列の最初に戻る
            newIndex = startIdx
        }
        let oldOffset = Const.calcOffset(index: oldIndex)
        let newOffset = Const.calcOffset(index: oldIndex + 1)
        // 時間をかけて値を変化させる
        let d = isDisabled.wrappedValue ? reelDurationSlow : reelDurationFast
        DispatchQueue.main.async {
            realState.index = newIndex
            realState.offset = oldOffset
            withAnimation(.linear(duration: d)) {
                realState.offset = newOffset
            }
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + d) {
            completion()
        }
    }
    
    private func canStop() -> Bool {
        return realState.stopIndex == realState.index
    }
    
    private func didStop() {
        self.isDisabled.wrappedValue = false
        self.selected.wrappedValue = dispArr[realState.index].pokedexId
        self.openDetailView.wrappedValue = true
        print("stopped at: \(realState.index), \(dispArr[realState.index].pokedexId)")
    }
}


#Preview {
    ContentView()
}

