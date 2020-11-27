<div align="center">
<img style="border-radius: 20%" src="https://map.pstatic.net/res/file/content/global/static/naver/og_map.png"/>

# 네이버 Map SDK를 활용한 POI Clustering Interaction Dev

**`부스트캠프 5기`** **5주 기업 프로젝트**

| [@SkydevilK](https://github.com/SkydevilK) | [@yskpth91](https://github.com/yskpth91) | [@hoonv](https://github.com/hoonv) | [@kyungpyoda](https://github.com/kyungpyoda) |
| :----------------------------------------: | :--------------------------------------: | :--------------------------------: | :------------------------------------------: |
|                S008_김병인                 |               S020_박태희                |            S058_채훈기             |                 S064_홍경표                  |

</div>

***

## 프로젝트 소개

<img height="220" alt="스크린샷 2020-11-20 오후 2 23 58" src="https://user-images.githubusercontent.com/46335714/99762626-4a544180-2b3c-11eb-9794-8a4c86acd217.png">
<img height="220" alt="스크린샷 2020-11-20 오후 2 40 40" src="https://user-images.githubusercontent.com/46335714/99762889-dc5c4a00-2b3c-11eb-8008-dddbb86eeaee.jpg">
<img height="220" src="https://user-images.githubusercontent.com/44656036/99764594-bdf84d80-2b40-11eb-9fa7-f7fe646e6fa7.gif">
    

### 📍 Clustering을 활용하여 UI, UX 면에서 개선된 지도 앱을 만들기 위한 프로젝트입니다.

  - 지도 위의 수많은 마커들을 보기 좋게 군집시킵니다.
  - 렌더링 부하가 줄어드는 효과도 기대할 수 있습니다.

## 기술 목표

- #### 성능 최적화 **16ms**🦅

  - Core Data를 멀티 스레드와 비동기를 이용하여 병목현상이 생기지 않게, Interaction에 문제가 없도록 할 것
  - 성능 개선을 위해 필요하다면 클러스터링 뿐만 아니라 필터링도 시도 할 것
  - 시간복잡도가 크지 않은 알고리즘 사용

- #### Awesome Interaction ⭐️

  - 슬라임 형식으로 마크들이 합쳐질 때, 흩어질 때 멋진 애니메이션
  - 마크 터치 시 두 가지 동작 방식
    - 적은 개수의 POI 데이터라면 TableView로 목록 띄우기 like AppleMap
    - 많은 개수라면 zoom -> cluster들을 spread
  - UX 친화적인 View 
    - 경고 표시할 때 단순한 알림창 보다는 적절한 애니메이션까지
    - Tap, Pinch 등 Interaction에 자연스럽고 부드러운 애니메이션

***

***

> ### [팀 Ground Rules](https://github.com/boostcamp-2020/Project17-A-Map/wiki/Team-Ground-Rules)
> ### [개발 Ground Rules](https://github.com/boostcamp-2020/Project17-A-Map/wiki/Ground-Rules-For-Dev)
> ### [Backlog](https://github.com/boostcamp-2020/Project17-A-Map/wiki/Backlog)

