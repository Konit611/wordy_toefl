import SwiftUI

struct SettingView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("설정")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.customBlack)
                    
                    VStack(spacing: 16) {
                        SettingRowView(title: "알림 설정", icon: "bell")
                        SettingRowView(title: "학습 목표", icon: "target")
                        SettingRowView(title: "앱 정보", icon: "info.circle")
                        SettingRowView(title: "문의하기", icon: "envelope")
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .background(Color.customBackgroundGreen)
        }
    }
}

struct SettingRowView: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.customCoolGray)
                .frame(width: 40)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.customBlack)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.customBlack)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.1), radius: 3, x: 0, y: 1)
    }
}

#Preview {
    SettingView()
} 