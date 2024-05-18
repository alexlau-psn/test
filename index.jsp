<%@ page language="java"
contentType="text/html; charset=UTF-8"
pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>中国地图</title>
    <style>
        html, body {
            overflow: hidden;
        }
        body {
            margin: 0;
            font-family: Arial, sans-serif;
            display: flex;
            flex-direction: column;
            height: 100vh;
            overflow-x: hidden;
        }
        .header {
            background-color: rgba(255, 255, 255, 0.5);
            padding: 8px 3px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            position: sticky;
            width: 100%;
            top: 0;
            z-index: 1000;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            flex-shrink: 0;
        }
        .header button {
            background: none;
            border: none;
            color: black;
            font-size: 20px;
            cursor: pointer;
        }
        .container {
            display: flex;
            flex: 1;
            width: 80%;
            box-sizing: border-box;
        }
        .sidebar {
            width: 150px;
            background-color: #f4f4f4;
            height: calc(100vh - 50px);
            overflow-y: auto;
            box-shadow: 2px 0 5px rgba(0, 0, 0, 0.1);
            padding-top: 10px;
            z-index: 1000;
            position: relative;
        }
        .sidebar button {
            display: block;
            width: 100%;
            background: none;
            border: none;
            color: black;
            padding: 15px;
            text-align: center;
            cursor: pointer;
            font-size: 16px;
            transition: background-color 0.3s;
        }
        .sidebar button:hover {
            background-color: #ddd;
        }
        .main-content {
            flex: 1;
            padding: 20px;
            text-align: center;
            position: relative;
            overflow: hidden;
        }
        .main-content img {
            max-width: 100%;
            max-height: 75%;
            transform-origin: top left;
            cursor: grab;
            position: relative;
        }
        .main-content .controls {
            position: absolute;
            bottom: 20px;
            left: 10px;
            display: flex;
            gap: 5px;
            z-index: 1001;
        }
        .main-content .controls button {
            background: white;
            border: 1px solid #ccc;
            border-radius: 3px;
            padding: 10px;
            cursor: pointer;
        }
        .province-button {
            position: absolute;
            background: none;
            border: none;
            color: rgb(26, 82, 238);
            font-size: 14px;
            cursor: pointer;
        }
        #popup {
            display: none;
            position: fixed;
            top: 10%;
            left: 10%;
            width: 80%;
            height: 80%;
            background-color: white;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.5);
            z-index: 2000;
        }
        #popup .popup-content {
            display: flex;
            height: 100%;
        }
        #popup .popup-content img {
            width: 70%;
            height: 100%;
        }
        #popup .popup-content .popup-sidebar {
            width: 30%;
            padding: 20px;
            overflow-y: auto;
            border-left: 1px solid #ddd;
        }
        #popup .close-button {
            position: absolute;
            top: 10px;
            right: 10px;
            background: none;
            border: none;
            font-size: 24px;
            cursor: pointer;
        }
    </style>
</head>
<body>
    <div class="header">
        <button onclick="alert('Button TBD')">Button1 TBD</button>
        <button onclick="alert('Button TBD')">Button2 TBD</button>
    </div>
    <div class="container">
        <div class="sidebar">
            <button onclick="alert('Button TBD')">Button3 TBD</button>
            <button onclick="alert('Button TBD')">Button4 TBD</button>
            <button onclick="alert('Button TBD')">Button5 TBD</button>
            <button onclick="alert('Button TBD')">Button6 TBD</button>
        </div>
        <div class="main-content" id="mainContent">
            <div id="mapContainer" style="position: relative; display: inline-block;">
                <img id="mapImage" src="<%=request.getContextPath() %>/images/map.png" alt="map">
                <button class="province-button" data-original-top="286" data-original-left="975" style="top: 286px; left: 975px;" onclick="showPopup('<%=request.getContextPath() %>/images/liaoning.png', '这里是省份1的详细信息')">沈阳</button>
                <button class="province-button" data-original-top="227" data-original-left="1005" style="top: 227px; left: 1005px;" onclick="showPopup('<%=request.getContextPath() %>/images/jilin.png', '这里是省份2的详细信息')">长春</button>
                <button class="province-button" data-original-top="175" data-original-left="1020" style="top: 175px; left: 1020px;" onclick="showPopup('<%=request.getContextPath() %>/images/heilongjiang.png', '这里是省份3的详细信息')">哈尔滨</button>
            </div>
            <div class="controls">
                <button onclick="zoomIn()" aria-label="Zoom In">
                    <svg width="24" height="24" viewBox="0 0 24 24">
                        <path d="M12 5v14m-7-7h14" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                    </svg>
                </button>
                <button onclick="zoomOut()" aria-label="Zoom Out">
                    <svg width="24" height="24" viewBox="0 0 24 24">
                        <path d="M5 12h14" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                    </svg>
                </button>
            </div>
        </div>
        <div class="right-sidebar">
            <p>测试</p>
        </div>
    </div>
    <div id="popup">
        <button class="close-button" onclick="hidePopup()">×</button>
        <div class="popup-content">
            <img id="popupImage" src="" alt="Province Map">
            <div class="popup-sidebar">
                <p id="popupText">这里是详细信息。</p>
            </div>
        </div>
    </div>
    <script>
        const mapImage = document.getElementById('mapImage');
        const mapContainer = document.getElementById('mapContainer');
        let scale = 1;
        let originX = 0;
        let originY = 0;
        let isDragging = false;
        let startX, startY;

        function zoomIn() {
            scale += 0.1;
            updateTransform();
        }

        function zoomOut() {
            if (scale > 0.2) {
                scale -= 0.1;
                updateTransform();
            }
        }

        function updateTransform() {
            mapContainer.style.transform = `scale(${scale}) translate(${originX}px, ${originY}px)`;
            mapContainer.style.transformOrigin = 'top left';
        }

        function onMouseDown(event) {
            event.preventDefault();
            isDragging = true;
            mapImage.style.cursor = 'grabbing';
            startX = event.clientX - originX * scale;
            startY = event.clientY - originY * scale;
        }

        function onMouseMove(event) {
            if (isDragging) {
                const dx = event.clientX - startX;
                const dy = event.clientY - startY;
                originX = dx / scale;
                originY = dy / scale;
                updateTransform();
            }
        }

        function onMouseUp() {
            isDragging = false;
            mapImage.style.cursor = 'grab';
        }

        function onMouseLeave() {
            isDragging = false;
            mapImage.style.cursor = 'grab';
        }

        mapImage.addEventListener('mousedown', onMouseDown);
        window.addEventListener('mousemove', onMouseMove);
        window.addEventListener('mouseup', onMouseUp);
        window.addEventListener('mouseleave', onMouseLeave);

        function showPopup(imageSrc, text) {
            document.getElementById('popupImage').src = imageSrc;
            document.getElementById('popupText').textContent = text;
            document.getElementById('popup').style.display = 'block';
        }

        function hidePopup() {
            document.getElementById('popup').style.display = 'none';
        }
    </script>
</body>
</html>
