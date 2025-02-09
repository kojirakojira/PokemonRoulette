//
//  Toast.swift
//  PokemonRoulette
//
//  Created by 佐久間涼 on 2025/01/31.
//

import SwiftUI

struct Toast: View {
    @ObservedObject var toastQueue: ToastQueue
    
    @State var title: String = ""
    @State var content: String = ""
    @State var isShow: Bool = false
    
    var body: some View {
        VStack {
            if isShow {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 30)
                        .foregroundColor(Color.green)
                    Spacer()
                    VStack(alignment: .leading) {
                        if (!title.isEmpty) {
                            Text(title)
                                .font(.custom("RoundedMplus1c-Bold", size: 16))
                                .foregroundColor(Color.black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        if (!content.isEmpty) {
                            Text(content)
                                .font(.custom("RoundedMplus1c-Regular", size: 14))
                                .foregroundColor(Color.black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    Spacer()
                }
                .frame(width: 400 < UIScreen.main.bounds.width * 1 / 2 ? 400 : UIScreen.main.bounds.width * 1 / 2)
                .padding(.all, 10)
                .background(Color(red: 232/255, green: 242/255, blue: 228/255))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                Spacer()
            }
        }
        .padding(.top, 50)
        .onChange(of: toastQueue.queue) { oldValue, newValue in
            // 追加された場合は正の数。削除された場合は負の数
            let incrOrDecr: Int = newValue.count - oldValue.count

            if ((incrOrDecr > 0 && oldValue.isEmpty) ||
                (incrOrDecr < 0 && !newValue.isEmpty)) {
                
                isShow = true
                // 1個目の追加、または最後の要素以外の削除の場合
                title = toastQueue.queue.first!.title
                content = toastQueue.queue.first!.content
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
                    // 3秒後にToastを閉じ、queueの最初の要素を削除する。
                    toastQueue.queue.removeFirst()
                    withAnimation {
                        isShow = false
                    }
                    
                    if (!toastQueue.queue.isEmpty) {
                        // まだqueueが存在している場合は、再度toastを表示する。
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            isShow = true
                        }
                    }
                }
            }
        }
        .animation(Animation.easeOut(duration: 0.2), value: isShow)
    }
}

struct ToastElement: Equatable {
    var title: String
    var content: String
    
    // Type Omitting
    static func elem(_ title: String, _ content: String) -> ToastElement {
        return ToastElement(title: title, content: content)
    }
}

class ToastQueue: ObservableObject {
    // 配列は操作させない
    @Published fileprivate var queue: [ToastElement] = []
    func append (_ toastElement: ToastElement) -> Void {
        queue.append(toastElement)
    }
}

#Preview {
    Toast(toastQueue: ToastQueue())
}
