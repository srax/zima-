# Deepfake AI Agent with Solana Integration

A comprehensive Flutter application that combines AI-powered deepfake agents with Solana blockchain functionality for token operations.

## 🚀 Features

### 🤖 AI Agent Platform
- **Real-time AI Agent Interaction** using D-ID API
- **WebRTC Video Streaming** for live agent communication
- **Voice Recording** and audio processing
- **Interactive Chat Interface** with AI responses

### 🔗 Solana Blockchain Integration
- **Mobile Wallet Adapter** support using Solana Mobile Stack (SMS)
- **Token Burning** - Permanently destroy tokens from your wallet
- **Token Locking** - Create time-locked vesting schedules using Jupiter Lock protocol
- **Real-time Balance Tracking** for SOL and SPL tokens
- **Transaction History** with detailed success/failure records
- **Multi-network Support** (Devnet/Mainnet)

### 📱 Cross-Platform Support
- Android (primary target with SMS integration)
- iOS
- Web
- Windows
- macOS
- Linux

## 🛠 Technology Stack

### Frontend
- **Flutter** - Cross-platform mobile framework
- **Provider** - State management
- **WebRTC** - Real-time video communication
- **Material 3** - Modern UI design system

### Blockchain
- **Solana Mobile Stack (SMS)** - Secure wallet connections
- **Meteora Token Lock & Burn Program** - Smart contract integration
- **Jupiter Lock Protocol** - Token vesting functionality
- **Solana Web3.js** - Blockchain interactions

### AI & Media
- **D-ID API** - AI agent video generation
- **Socket.IO** - Real-time communication
- **Flutter WebRTC** - Video streaming capabilities

## 📋 Prerequisites

- Flutter SDK (3.8.1 or higher)
- Android Studio / Xcode for mobile development
- Solana wallet app with SMS support (Phantom, Solflare, etc.)
- D-ID API key for AI agent functionality

## 🔧 Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd deepfake
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment**
   ```bash
   # Set your D-ID API key in the appropriate configuration file
   # Configure Solana network (Devnet/Mainnet) in wallet/apis/solana_config.dart
   ```

4. **Run the application**
   ```bash
   flutter run
   ```

## 🎮 Usage

### Getting Started
1. **Launch the app** and complete the onboarding flow
2. **Login** with credentials: `grkashani@gmail.com` / `R!e2z3a4`
3. **Navigate** between different features using the bottom navigation

### Solana Wallet Features

#### Connecting Your Wallet
1. Go to the **Wallet** tab in the bottom navigation
2. Tap **"Connect Wallet"**
3. Choose your preferred Solana wallet app
4. Approve the connection request

#### Burning Tokens
1. Navigate to **Wallet > Operations > Burn Tokens**
2. Select the token you want to burn
3. Enter the amount to destroy
4. Provide your token account address
5. Review the warning and confirm the transaction

#### Locking Tokens
1. Navigate to **Wallet > Operations > Lock Tokens**
2. Select the token to lock
3. Set the recipient address
4. Configure lock parameters:
   - **Cliff Time**: Initial lock period before any unlock
   - **Frequency**: How often tokens are released
   - **Cliff Amount**: Tokens unlocked after cliff period
   - **Amount Per Period**: Tokens released each period
   - **Number of Periods**: Total release cycles
5. Review the summary and confirm

#### Viewing Transaction History
- Check the **History** tab for all your transactions
- View transaction signatures and explorer links
- Monitor success/failure status

### AI Agent Interaction
1. Go to the **Agents** tab
2. Select or create an AI agent
3. Start a video call with real-time interaction
4. Use text chat alongside video communication

## 🔐 Security

- **Non-custodial**: Your private keys never leave your wallet app
- **SMS Integration**: Secure transaction signing via Mobile Wallet Adapter
- **Read-only Access**: App only reads public data until you approve transactions
- **On-chain Validation**: All transactions are verified on the Solana blockchain

## 🏗 Architecture

The app follows a clean, feature-based architecture:

```
lib/
├── main.dart                 # App entry point
├── app/                      # Shared components and utilities
├── onboarding/               # Onboarding flow
├── auth/                     # Authentication system
├── home/                     # Main navigation
├── agent/                    # AI agent functionality
├── wallet/                   # Solana wallet integration
│   ├── models/               # Data models
│   ├── apis/                 # Blockchain API layer
│   ├── providers/            # State management
│   └── presentation/         # UI components
└── [other features]/
```

### Key Components

- **WalletProvider**: Manages wallet state and operations
- **SolanaClient**: Handles blockchain connections and transactions
- **MeteoraProgamApi**: Interfaces with token lock/burn smart contracts
- **Mobile Wallet Adapter**: Secure wallet integration

## 📊 Smart Contracts

### Meteora Token Lock & Burn Program
- **Program ID**: `5VDexKtW25RjF4eVRPQRopkYQAyqmKU3M4EGK9D34VLB` (Devnet)
- **Jupiter Lock Integration**: `LocpQgucEQHbqNABEYvBvwoxCPsSbG91A1QaQhQQqjn`
- **Functions**:
  - `proxy_lock`: Creates time-locked token vesting
  - `token_burn`: Permanently destroys tokens

## 🌐 Network Configuration

### Devnet (Development)
- RPC: `https://api.devnet.solana.com`
- Explorer: `https://solscan.io/?cluster=devnet`
- Test tokens available via faucet

### Mainnet (Production)
- RPC: `https://api.mainnet-beta.solana.com`
- Explorer: `https://solscan.io/`
- Real SOL and tokens required

## 🧪 Testing

Run tests with:
```bash
flutter test
```

### Test Structure
- Unit tests for business logic
- Widget tests for UI components
- Integration tests for wallet functionality

## 🔧 Development

### Common Commands
```bash
flutter run                          # Run in debug mode
flutter build apk                    # Build Android APK
flutter build ios                    # Build iOS app
flutter analyze                      # Static code analysis
flutter pub upgrade                  # Update dependencies
```

### Environment Variables
```bash
# Override server URL
flutter run --dart-define=SERVER_URL=http://localhost:4000
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

### Common Issues

**Wallet Connection Failed**
- Ensure you have a Solana Mobile Stack compatible wallet installed
- Check your internet connection
- Verify the app has necessary permissions

**Transaction Failed**
- Ensure sufficient SOL balance for transaction fees
- Check token account ownership
- Verify network connectivity

**AI Agent Not Loading**
- Check D-ID API key configuration
- Verify internet connection for WebRTC
- Ensure camera/microphone permissions

### Resources
- [Flutter Documentation](https://docs.flutter.dev/)
- [Solana Mobile Stack](https://github.com/solana-mobile/solana-mobile-stack-sdk)
- [D-ID API Documentation](https://docs.d-id.com/)

## 🔗 Links

- [Solana Explorer](https://solscan.io/)
- [Jupiter Lock Protocol](https://jup.ag/lock)
- [D-ID Platform](https://www.d-id.com/)
- [Flutter Development](https://flutter.dev/)

---

Built with ❤️ using Flutter and Solana