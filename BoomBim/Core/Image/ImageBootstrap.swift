//
//  ImageBootstrap.swift
//  BoomBim
//
//  Created by 조영현 on 8/28/25.
//

import Nuke

enum ImageBootstrap {
    static func configure() {
        var conf = ImagePipeline.Configuration()
        conf.isProgressiveDecodingEnabled = true
        conf.dataCache = try? DataCache(name: "com.boombim.images") // 디스크 캐시
//        conf.dataCache?.sizeLimit = 200 * 1024 * 1024               // 200MB
        conf.imageCache = ImageCache.shared                         // 메모리 캐시

        ImagePipeline.shared = ImagePipeline(configuration: conf)
        // 기본 옵션 (placeholder/전환 효과 등)도 글로벌로 지정 가능
//        ImageLoadingOptions.shared.transition = .fadeIn(duration: 0.2)
    }
}
