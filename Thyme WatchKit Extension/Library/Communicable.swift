protocol Communicable: class {
    var wormhole: MMWormhole! { get set }
    var listeningWormhole: MMWormholeSession! { get set }
    var communicationConfigured: Bool { get }

    func configureCommunication()
}

extension Communicable {
    func configureSession() {
        listeningWormhole = MMWormholeSession.sharedListening()

        wormhole = MMWormhole(
            applicationGroupIdentifier: AppGroup.identifier,
            optionalDirectory: AppGroup.optionalDirectory,
            transitingType: .sessionMessage)
    }
}
