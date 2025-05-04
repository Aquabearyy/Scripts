// ==UserScript==
// @name         ModMate
// @namespace    https://modmatee.vercel.app
// @version      0.8
// @description  Fast XP farming for Duolingo with auto-update
// @author       ModMate
// @match        https://*.duolingo.com/*
// @icon         https://www.google.com/s2/favicons?sz=64&domain=duolingo.com
// @grant        none
// @license      none
// @updateURL    https://github.com/Aquabearyy/Scripts/raw/refs/heads/main/modmate.user.js
// @downloadURL  https://github.com/Aquabearyy/Scripts/raw/refs/heads/main/modmate.user.js
// @supportURL   https://modmatee.vercel.app
// ==/UserScript==

(function() {
    'use strict';
    
    const scriptVersion = '0.8';
    const scriptName = 'ModMate';
    const sessionUrl = "https://www.duolingo.com/2017-06-30/sessions";
    let isFarming = false;
    let isVisible = true;
    let xpGained = 0;
    let totalSessionsDone = 0;
    let concurrentRequests = 10;

    const checkForUpdates = async () => {
        try {
            const statusElement = document.getElementById("_loginStatus");
            if (statusElement) {
                statusElement.innerHTML += `<br/><small>Version ${scriptVersion}</small>`;
            }
            
            console.log(`${scriptName} v${scriptVersion} loaded successfully`);
            console.log('Auto-updates enabled through userscript manager');
            console.log('Support website: https://modmatee.vercel.app');
        } catch (error) {
            console.error("Error checking for updates:", error);
        }
    };

    const getJwtToken = () => document.cookie.split(';').find(c => c.trim().startsWith('jwt_token='))?.split('=')[1] || null;

    const decodeJwtToken = token => {
        try {
            return JSON.parse(atob(token.split('.')[1].replace(/-/g, '+').replace(/_/g, '/')));
        } catch (e) {
            console.error("Error decoding JWT token:", e);
            return {};
        }
    };

    const formatHeaders = jwtToken => ({
        "Content-Type": "application/json",
        "Authorization": `Bearer ${jwtToken}`,
        "User-Agent": navigator.userAgent
    });

    const getUserInfo = async (sub, headers) => {
        try {
            const response = await fetch(`https://www.duolingo.com/2017-06-30/users/${sub}?fields=username,fromLanguage,learningLanguage`, { headers });
            return await response.json();
        } catch (error) {
            return { username: "Unknown", fromLanguage: "en", learningLanguage: "es" };
        }
    };

    const updateStatusDisplay = () => {
        const statusElement = document.getElementById("_statusInfo");
        if (statusElement) {
            statusElement.innerHTML = `XP: ${xpGained} | Sessions: ${totalSessionsDone}`;
        }

        const xpAmountElement = document.getElementById("_xpAmount");
        if (xpAmountElement) {
            xpAmountElement.innerText = xpGained;
        }
    };

    const processSession = async (headers, sessionPayload, updateSessionPayload) => {
        try {
            const sessionResponse = await fetch(sessionUrl, {
                method: 'POST',
                headers,
                body: JSON.stringify(sessionPayload)
            });

            if (!sessionResponse.ok) return 0;

            const session = await sessionResponse.json();

            await new Promise(r => setTimeout(r, Math.floor(Math.random() * 100) + 1));

            const updateResponse = await fetch(`${sessionUrl}/${session.id}`, {
                method: 'PUT',
                headers,
                body: JSON.stringify({ ...session, ...updateSessionPayload })
            });

            if (!updateResponse.ok) return 0;

            const updatedSession = await updateResponse.json();

            return updatedSession.xpGain || 0;
        } catch (error) {
            return 0;
        }
    };

    const processSessionsBatch = async (count, headers, sessionPayload, updateSessionPayload) => {
        try {
            const promises = [];

            for (let i = 0; i < count; i++) {
                promises.push(processSession(headers, sessionPayload, updateSessionPayload));
            }

            const results = await Promise.all(promises);
            const totalXpGained = results.reduce((sum, xp) => sum + xp, 0);

            return { xp: totalXpGained, count: results.filter(xp => xp > 0).length };
        } catch (error) {
            return { xp: 0, count: 0 };
        }
    };

    const farmXp = async (headers, sessionPayload, updateSessionPayload) => {
        xpGained = 0;
        totalSessionsDone = 0;
        updateStatusDisplay();

        while (isFarming) {
            try {
                const { xp, count } = await processSessionsBatch(
                    concurrentRequests,
                    headers,
                    sessionPayload,
                    updateSessionPayload
                );

                xpGained += xp;
                totalSessionsDone += count;
                updateStatusDisplay();

                if (!isFarming) break;

                await new Promise(resolve => setTimeout(resolve, 10));

            } catch (error) {
                isFarming = false;
                updateStatusDisplay();
                break;
            }
        }
    };

    const createUserInterface = () => {
        const duoFarmerHTML = `
            <div class="_container" id="_container">
                <div class="_header">
                    <p class="_title">${scriptName}</p>
                </div>
                <div class="_description">
                    <p id="_loginStatus">Checking login...</p>
                </div>
                <div class="_content">
                    <button class="_startBtn" id="_startBtn">Start Farming</button>
                </div>
                <div class="_statusContainer">
                    <p id="_statusInfo" class="_statusInfo">Ready</p>
                </div>
            </div>
            <button class="_toggleBtn" id="_toggleBtn">→</button>
            <div class="_overlay" id="_loadingOverlay">
                <div class="_swalModal">
                    <h2>${scriptName}</h2>
                    <div class="_spinner"></div>
                    <div class="_xpInfo">+ <span id="_xpAmount">0</span> XP</div>
                    <button id="_stopBtn">Stop</button>
                </div>
            </div>
        `;

        const container = document.createElement('div');
        container.id = '_duofarmer_container';
        container.innerHTML = duoFarmerHTML;

        const existingContainer = document.getElementById('_duofarmer_container');
        if (existingContainer) {
            existingContainer.remove();
        }

        document.body.appendChild(container);

        const style = document.createElement('style');
        style.textContent = `
            #_duofarmer_container {
                font-family: "din-round", sans-serif;
                position: relative;
                z-index: 9999;
            }

            ._container {
                position: fixed;
                right: 10px;
                bottom: 50px;
                width: 200px;
                padding: 10px;
                background: #fff;
                border: 2px solid #58cc02;
                border-radius: 12px;
                box-shadow: 0 8px 20px rgba(0,0,0,.3);
                transition: transform .5s, opacity .5s;
                z-index: 9999;
            }

            ._container.hidden {
                transform: translateX(110%);
                opacity: 0;
            }

            ._toggleBtn {
                position: fixed;
                right: 10px;
                top: 40%;
                width: 35px;
                height: 35px;
                background: #58cc02;
                color: #fff;
                border: none;
                border-radius: 50%;
                display: flex;
                justify-content: center;
                align-items: center;
                cursor: pointer;
                z-index: 10000;
            }

            ._header {
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-bottom: 10px;
            }

            ._title {
                font-size: 1.1rem;
                color: #58cc02;
                font-weight: 700;
                margin: 0;
            }

            ._description {
                font-size: .9rem;
                margin-bottom: 15px;
                padding: 8px;
                background: #f9f9f9;
                border-left: 4px solid #58cc02;
                border-radius: 8px;
                color: #444;
            }

            ._startBtn {
                width: 100%;
                padding: 10px;
                border: none;
                border-radius: 8px;
                font-size: 1rem;
                background: #58cc02;
                color: #fff;
                font-weight: 700;
                cursor: pointer;
            }

            ._startBtn:disabled {
                background: #cccccc;
                cursor: not-allowed;
            }

            ._statusContainer {
                margin: 10px 0;
                padding: 8px;
                background: #f5f5f5;
                border-radius: 8px;
            }

            ._statusInfo {
                font-size: .9rem;
                margin: 0;
                color: #555;
            }

            ._overlay {
                position: fixed;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                background: rgba(0,0,0,.4);
                display: none;
                align-items: center;
                justify-content: center;
                z-index: 9999;
            }

            ._swalModal {
                background: #fff;
                border-radius: 12px;
                padding: 20px;
                width: 300px;
                text-align: center;
                box-shadow: 0 0 20px rgba(0,0,0,.2);
            }

            ._swalModal h2 {
                color: #58cc02;
                font-size: 1.7em;
                margin: 0 0 .4em;
                font-weight: 700;
            }

            ._swalModal ._xpInfo {
                color: #58cc02;
                font-size: 1.2em;
                margin: 1em 0;
                font-weight: bold;
            }

            ._swalModal button {
                background-color: #ff4b4b;
                color: #fff;
                border: 0;
                border-radius: .5em;
                font-size: 1.075em;
                padding: 10px 24px;
                margin: 15px 5px 0;
                cursor: pointer;
            }

            ._spinner {
                display: inline-block;
                width: 60px;
                height: 60px;
                margin: 15px;
            }

            ._spinner:after {
                content: " ";
                display: block;
                width: 50px;
                height: 50px;
                border-radius: 50%;
                border: 5px solid #58cc02;
                border-color: #58cc02 transparent;
                animation: 1.2s linear infinite spinnerRotate;
            }

            @keyframes spinnerRotate {
                0% { transform: rotate(0); }
                100% { transform: rotate(360deg); }
            }
        `;

        document.head.appendChild(style);
    };

    const initDuoFarmer = async () => {
        createUserInterface();
        
        await checkForUpdates();

        const JWT = getJwtToken();
        if (!JWT) {
            document.getElementById("_startBtn").disabled = true;
            document.getElementById("_loginStatus").innerText = "Not logged in! Refresh page.";
            return;
        }

        const HEADERS = formatHeaders(JWT);

        try {
            const decodedToken = decodeJwtToken(JWT);
            const { username, fromLanguage, learningLanguage } = await getUserInfo(decodedToken.sub, HEADERS);

            document.getElementById("_loginStatus").innerHTML = `
                <strong>${username}</strong> | ${learningLanguage}
                <br/><small>Version ${scriptVersion}</small>
            `;

            const sessionPayload = {
                challengeTypes: ["assist","characterIntro","characterMatch","characterPuzzle","characterSelect","characterTrace","characterWrite","completeReverseTranslation","definition","dialogue","extendedMatch","extendedListenMatch","form","freeResponse","gapFill","judge","listen","listenComplete","listenMatch","match","name","listenComprehension","listenIsolation","listenSpeak","listenTap","orderTapComplete","partialListen","partialReverseTranslate","patternTapComplete","radioBinary","radioImageSelect","radioListenMatch","radioListenRecognize","radioSelect","readComprehension","reverseAssist","sameDifferent","select","selectPronunciation","selectTranscription","svgPuzzle","syllableTap","syllableListenTap","speak","tapCloze","tapClozeTable","tapComplete","tapCompleteTable","tapDescribe","translate","transliterate","transliterationAssist","typeCloze","typeClozeTable","typeComplete","typeCompleteTable","writeComprehension"],
                fromLanguage,
                learningLanguage,
                type: "GLOBAL_PRACTICE"
            };

            const updateSessionPayload = {
                heartsLeft: 0,
                startTime: Math.floor(Date.now() / 1000),
                enableBonusPoints: false,
                endTime: Math.floor(Date.now() / 1000) + 112,
                failed: false,
                maxInLessonStreak: 9,
                shouldLearnThings: true
            };

            document.getElementById("_toggleBtn").addEventListener("click", () => {
                isVisible = !isVisible;
                const container = document.getElementById("_container");
                container.classList.toggle("hidden", !isVisible);
                document.getElementById("_toggleBtn").innerHTML = isVisible ? "→" : "←";
            });

            const startBtn = document.getElementById("_startBtn");
            startBtn.addEventListener("click", () => {
                document.getElementById("_loadingOverlay").style.display = "flex";
                isFarming = true;
                xpGained = 0;
                document.getElementById("_xpAmount").innerText = "0";
                farmXp(HEADERS, sessionPayload, updateSessionPayload);
            });

            document.getElementById("_stopBtn").addEventListener("click", () => {
                document.getElementById("_loadingOverlay").style.display = "none";
                isFarming = false;
                startBtn.disabled = true;
                startBtn.innerText = "Cooldown...";
                updateStatusDisplay();

                setTimeout(() => {
                    startBtn.disabled = false;
                    startBtn.innerText = "Start Farming";
                }, 2000);
            });
        } catch (error) {
            document.getElementById("_loginStatus").innerHTML = "Error initializing.";
        }
    };

    window.addEventListener('load', () => {
        setTimeout(initDuoFarmer, 1500);
    });
})();
