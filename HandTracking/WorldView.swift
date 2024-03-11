//
//  WorldView.swift
//  HandTracking
//
//  Created by Tomáš Pařízek on 11.03.2024.
//

import ARKit
import SwiftUI
import RealityKit

struct WorldView: View {

    private var fingerEntityRight1 = makeFingerEntity()
    private var fingerEntityRight2 = makeFingerEntity()
    private var fingerEntityRight3 = makeFingerEntity()
    private var fingerEntityRight4 = makeFingerEntity()
    private var fingerEntityRight5 = makeFingerEntity()
    private var fingerEntityLeft1 = makeFingerEntity()
    private var fingerEntityLeft2 = makeFingerEntity()
    private var fingerEntityLeft3 = makeFingerEntity()
    private var fingerEntityLeft4 = makeFingerEntity()
    private var fingerEntityLeft5 = makeFingerEntity()

    private let session = ARKitSession()
    private let handTrackingProvider = HandTrackingProvider()

    var body: some View {
        RealityView { content in
            fingerEntities.forEach {
                content.add($0)
            }
        }
        .task {
            do {
                try await session.run([handTrackingProvider])

                for await anchorUpdate in handTrackingProvider.anchorUpdates {
                    process(anchorUpdate: anchorUpdate)
                }
            } catch {
                print("Error: \(error)")
            }
        }
    }
}

private extension WorldView {
    func process(anchorUpdate: AnchorUpdate<HandAnchor>) {
        guard
            anchorUpdate.event == .added || anchorUpdate.event == .updated,
            anchorUpdate.anchor.isTracked,
            let handSkeleton = anchorUpdate.anchor.handSkeleton
        else { return }

        let handFinderEntities = switch anchorUpdate.anchor.chirality {
        case .left:
            leftFingerEntities
        case .right:
            rightFingerEntities
        }

        let joints = [
            handSkeleton.joint(.thumbTip),
            handSkeleton.joint(.indexFingerTip),
            handSkeleton.joint(.middleFingerTip),
            handSkeleton.joint(.ringFingerTip),
            handSkeleton.joint(.littleFingerTip)
        ]

        for (entity, joint) in zip(handFinderEntities, joints) where joint.isTracked {
            entity.setTransformMatrix(
                anchorUpdate.anchor.originFromAnchorTransform * joint.anchorFromJointTransform,
                relativeTo: nil
            )
        }

        zip(leftFingerEntities, rightFingerEntities).forEach { leftEntity, rightEntity in
            let distance = simd_distance(leftEntity.position, rightEntity.position)
            let color = distance < 0.015 ? UIColor.green : UIColor.red
            leftEntity.model?.materials = [SimpleMaterial(color: color, isMetallic: false)]
            rightEntity.model?.materials = [SimpleMaterial(color: color, isMetallic: false)]
        }
    }

    var fingerEntities: [ModelEntity] {
        [rightFingerEntities, leftFingerEntities].flatMap { $0 }
    }

    var rightFingerEntities: [ModelEntity] {
        [
            fingerEntityRight1,
            fingerEntityRight2,
            fingerEntityRight3,
            fingerEntityRight4,
            fingerEntityRight5
        ]
    }

    var leftFingerEntities: [ModelEntity] {
        [
            fingerEntityLeft1,
            fingerEntityLeft2,
            fingerEntityLeft3,
            fingerEntityLeft4,
            fingerEntityLeft5
        ]
    }

    static func makeFingerEntity() -> ModelEntity {
        ModelEntity(
            mesh: .generateSphere(radius: 0.01),
            materials: [SimpleMaterial(color: .red, isMetallic: false)]
        )
    }
}
