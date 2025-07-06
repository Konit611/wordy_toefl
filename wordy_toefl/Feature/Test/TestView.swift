import SwiftUI

struct TestView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("테스트")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.customBlack)
                    
                    VStack(spacing: 16) {
                        TestCardView(
                            title: "빠른 테스트",
                            description: "5분 내로 빠르게 테스트해보세요",
                            color: .customCoolGray,
                            icon: "bolt"
                        )
                        
                        TestCardView(
                            title: "종합 테스트",
                            description: "모든 단어를 포함한 종합 테스트",
                            color: .customGray2,
                            icon: "book"
                        )
                        
                        TestCardView(
                            title: "복습 테스트",
                            description: "틀린 문제들을 다시 테스트",
                            color: .customGray0,
                            icon: "arrow.clockwise"
                        )
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .background(Color.customBackgroundGreen)
        }
    }
}

struct TestCardView: View {
    let title: String
    let description: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    print("\(title) 테스트 시작")
                }) {
                    Image(systemName: "arrow.up.right")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(Color.customBackgroundGreen)
                        .clipShape(Circle())
                }
            }
            
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text(description)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(20)
        .background(color)
        .cornerRadius(16)
        .shadow(color: .gray.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    TestView()
} 