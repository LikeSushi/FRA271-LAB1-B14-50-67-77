function summary = process_static_data(dataDir)
% PROCESS_STATIC_DATA ประมวลผลและรวบรวมค่าสถิติของการทดลองแม่เหล็กและแรงดัน
%
% Inputs:
%   dataDir - พาธโฟลเดอร์หลักที่มีหมวดหมู่ RAW C / RAW D
%
% Outputs:
%   summary - Struct สรุปค่าประมวลผลแยกตามหมวดหมู่ (dists, meanFlux, stdFlux, meanVolt, stdVolt)

    categories = {'RAW C - No Shield', 'RAW C - Shield', 'RAW D - No Shield', 'RAW D - Shield'};
    summary = struct();

    for c = 1:length(categories)
        catName = categories{c};
        catPath = fullfile(dataDir, catName);
        if ~exist(catPath, 'dir')
            catPath = fullfile(dataDir, 'เก็บใหม่จากไนซ์', catName);
        end
        
        files = dir(fullfile(catPath, '*.mat'));
        if isempty(files)
            warning('ไม่พบไฟล์ .mat ในหมวดหมู่: %s', catName);
            continue;
        end

        distMapFlux = containers.Map('KeyType', 'double', 'ValueType', 'any');
        distMapVolt = containers.Map('KeyType', 'double', 'ValueType', 'any');

        for f = 1:length(files)
            fname = files(f).name;

            if contains(fname, 'Realtime', 'IgnoreCase', true)
                continue;
            end

            tokens = regexp(fname, '(\d+\.\d+|\d+)cm', 'tokens');
            if isempty(tokens)
                continue;
            end
            dist = str2double(tokens{1}{1});

            filePath = fullfile(catPath, fname);
            [~, sigs, sigNames] = load_lab_data(filePath);

            if isempty(sigs)
                continue;
            end

            fluxData = [];
            voltData = [];

            for idx = 1:length(sigNames)
                sName = sigNames{idx};
                if contains(sName, 'flux', 'IgnoreCase', true)
                    fluxData = sigs(:, idx);
                elseif contains(sName, 'voltage', 'IgnoreCase', true)
                    voltData = sigs(:, idx);
                end
            end

            if isempty(fluxData) || isempty(voltData)
                continue;
            end

            meanFlux = mean(abs(fluxData));
            rmsFlux  = rms(fluxData);
            peakFlux = max(abs(fluxData));

            meanVolt = mean(voltData);
            rmsVolt  = rms(voltData);

            if ~isKey(distMapFlux, dist)
                distMapFlux(dist) = [];
                distMapVolt(dist) = [];
            end
            distMapFlux(dist) = [distMapFlux(dist); [meanFlux, rmsFlux, peakFlux]];
            distMapVolt(dist) = [distMapVolt(dist); [meanVolt, rmsVolt]];
        end

        dists = sort(cell2mat(keys(distMapFlux)));
        dists = dists(:); % Force column vector Nx1

        meanFluxArr = zeros(length(dists), 1);
        stdFluxArr  = zeros(length(dists), 1);
        meanVoltArr = zeros(length(dists), 1);
        stdVoltArr  = zeros(length(dists), 1);

        for i = 1:length(dists)
            distVal = dists(i);
            fluxMat = distMapFlux(distVal);
            voltMat = distMapVolt(distVal);

            meanFluxArr(i) = mean(fluxMat(:, 1));
            stdFluxArr(i)  = std(fluxMat(:, 1));
            meanVoltArr(i) = mean(voltMat(:, 1));
            stdVoltArr(i)  = std(voltMat(:, 1));
        end

        fieldKey = strrep(strrep(catName, ' - ', '_'), ' ', '_');
        summary.(fieldKey).dists    = dists(:);
        summary.(fieldKey).meanFlux = meanFluxArr(:);
        summary.(fieldKey).stdFlux  = stdFluxArr(:);
        summary.(fieldKey).meanVolt = meanVoltArr(:);
        summary.(fieldKey).stdVolt  = stdVoltArr(:);
    end
end
