//
//  SettingsView.swift
//  PaceKit
//
//  Created by Calvin Korver on 4/7/25.
//

import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                
                Text("Last Updated: April 6, 2025")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 10)
                
                policySection(title: "Introduction", content: "Thank you for choosing to use our application (\"App\"). This Privacy Policy is designed to help you understand how we handle information when you use our App.")
                
                policySection(title: "Information We Do Not Collect", content: "Our App is designed with your privacy in mind. We do not collect any personal information that could be used to identify you, including but not limited to:\n\n• Names, email addresses, or physical addresses\n• Phone numbers\n• Device identifiers or IP addresses\n• Location data\n• Browsing history\n• User-generated content")
                
                policySection(title: "Limited Data Collection", content: "Our App operates without collecting, storing, or transmitting any personalizable user data. Any information processed by the App remains on your device and is not accessible to us or any third parties.")
                
                policySection(title: "Third-Party Services", content: "Our App does not integrate with third-party analytics tools, advertising networks, or other services that might collect user data.")
                
                policySection(title: "Data Security", content: "Since we do not collect or store any user data, there is no risk of your personal information being compromised through our App.")
                
                policySection(title: "Children's Privacy", content: "Our App does not collect information from anyone, including children under the age of 13.")
                
                policySection(title: "Changes to This Privacy Policy", content: "We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the \"Last Updated\" date.")
                
                policySection(title: "Contact Us", content: "If you have any questions about this Privacy Policy, please contact us at:\n\n[Your Contact Information]")
                
                policySection(title: "Compliance with Apple App Store Guidelines", content: "This App complies with Apple's App Store Review Guidelines regarding privacy and data collection practices. As required by the App Store, we provide this privacy policy explaining our data collection practices, which in this case is that we do not collect any personalizable user data.")
                
                Spacer(minLength: 40)
                
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Close")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.bottom)
            }
            .padding()
        }
        .navigationTitle("Privacy Policy")
    }
    
    private func policySection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
            
            Text(content)
                .font(.body)
        }
    }
}

struct PrivacyPolicyView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PrivacyPolicyView()
        }
    }
}

// Add this to your SettingsView to link to the privacy policy
struct SettingsView: View {
    @EnvironmentObject var modelData: ModelData
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: PrivacyPolicyView()) {
                    Text("Privacy Policy")
                }
                // Add other settings options here
            }
            .navigationTitle("Settings")
        }
    }
}
