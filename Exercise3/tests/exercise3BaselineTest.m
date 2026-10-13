classdef exercise3BaselineTest < matlab.unittest.TestCase
    %EXERCISE3BASELINETEST Verify the starter without generated solution files.
    properties
        Paths
    end

    methods (TestMethodSetup)
        function selectWorkshop(testCase)
            previousPath = path;
            previousRandomStream = rng;
            testCase.addTeardown(@() path(previousPath));
            testCase.addTeardown(@() rng(previousRandomStream));
            exercise3Folder = fileparts(fileparts(mfilename("fullpath")));
            addpath(exercise3Folder);
            testCase.Paths = setupExercise3();
        end
    end

    methods (Test)
        function setupBeforeAnySolutionExists(testCase)
            testCase.applyFixture(matlab.unittest.fixtures.CurrentFolderFixture( ...
                fileparts(testCase.Paths.Exercise3Folder)));
            generatedFiles = ["Exercise3_CharacterizedWideAreaSurveillance.m", ...
                "helperRunWideAreaSurveillanceTrackingWithComparison.m", ...
                "exercise3_characterized_ospa_comparison.png"];
            testCase.assertFalse(any(isfile(fullfile(testCase.Paths.Exercise3Folder, generatedFiles))), ...
                "The distributed starter must not contain generated solution files.");
            beforeFiles = dir(fullfile(testCase.Paths.Exercise3Folder, "**", "*"));
            previousFolder = pwd;
            previousRandomStream = rng;
            previousFigures = findall(groot, "Type", "figure");
            paths = setupExercise3();
            testCase.verifyTrue(isfile(paths.BaselineScript));
            testCase.verifyTrue(isfile(paths.PromptFile));
            testCase.verifyTrue(isfile(paths.BaselineFile));
            testCase.verifyTrue(isfile(paths.RadarFile));
            testCase.verifyEqual(pwd, previousFolder);
            testCase.verifyEqual(rng, previousRandomStream, AbsTol=0);
            testCase.verifyEqual(findall(groot, "Type", "figure"), previousFigures);
            testCase.verifyEqual(dir(fullfile(paths.Exercise3Folder, "**", "*")), beforeFiles);
        end

        function prepareCopiedShortScenario(testCase)
            % Exercise publication on a disposable copy, never on the supplied baseline.
            folder = testCase.applyFixture(matlab.unittest.fixtures.TemporaryFolderFixture);
            copiedExercise3 = fullfile(folder.Folder, "Exercise3");
            copyfile(testCase.Paths.Exercise3Folder, copiedExercise3);
            % Remove only the disposable copy's baseline to test first-time preparation.
            delete(fullfile(copiedExercise3, "Exercise3_OriginalBaselineResults.mat"));
            sourceFile = fullfile(copiedExercise3, "Exercise3_WideAreaSurveillance.m");
            source = string(fileread(sourceFile));
            source = replace(source, ...
                "scenario = helperCreateWideAreaSurveillanceScenario(groundRadar);", ...
                "scenario = helperCreateWideAreaSurveillanceScenario(groundRadar);" + newline + ...
                "scenario.StopTime = 2;");
            writelines(source, sourceFile);
            testCase.applyFixture(matlab.unittest.fixtures.CurrentFolderFixture(copiedExercise3));
            previousFigures = findall(groot, "Type", "figure");
            previousRandomStream = rng;
            previousPath = path;
            testCase.addTeardown(@() closeNewFigures(previousFigures));
            clear prepareExercise3Baseline setupExercise3
            file = prepareExercise3Baseline();
            [results, metadata] = helperLoadExercise3Baseline(file);
            testCase.verifyEqual(results.Time, (0:2)', AbsTol=0);
            testCase.verifyEqual(metadata.Scenario.StopTime, 2, AbsTol=0);
            testCase.verifyEqual(rng, previousRandomStream, AbsTol=0);
            testCase.verifyEqual(path, previousPath);
            testCase.verifyEqual(string(fileparts(file)), string(copiedExercise3));
        end

        function loadFullBaselineWithoutGraphics(testCase)
            previousFigures = findall(groot, "Type", "figure");
            [results, metadata] = helperLoadExercise3Baseline(testCase.Paths.BaselineFile);
            testCase.verifyEqual(findall(groot, "Type", "figure"), previousFigures);
            testCase.verifyEqual(results.Time, (0:100)', AbsTol=0);
            testCase.verifySize(results.OSPA, [101 1]);
            testCase.verifySize(results.SensorDataLog, [101 1]);
            testCase.verifySize(results.TruthDataLog, [101 1]);
            testCase.verifyFalse(isfield(results, "ViewerFigure"));
            testCase.verifyEqual(double(metadata.RandomStream.Seed), 2020, AbsTol=0);
            testCase.verifyEqual(string(metadata.RandomStream.Type), "twister");
            testCase.verifyNotEmpty(metadata.Sources);
            testCase.verifyNotEmpty(metadata.WaypointData);
        end

        function missingBaselineIsActionable(testCase)
            folder = testCase.applyFixture(matlab.unittest.fixtures.TemporaryFolderFixture);
            testCase.verifyError(@() helperLoadExercise3Baseline(fullfile(folder.Folder, "missing.mat")), ...
                "Exercise3:MissingBaseline");
        end

        function rejectMetricsOnlyBaseline(testCase)
            folder = testCase.applyFixture(matlab.unittest.fixtures.TemporaryFolderFixture);
            baselineResults = struct(Time=(0:100)', OSPA=zeros(101, 1));
            file = fullfile(folder.Folder, "metricsOnly.mat");
            save(file, "baselineResults");
            testCase.verifyError(@() helperLoadExercise3Baseline(file), "Exercise3:InvalidBaseline");
        end

        function rejectMisalignedLogs(testCase)
            folder = testCase.applyFixture(matlab.unittest.fixtures.TemporaryFolderFixture);
            [baselineResults, baselineMetadata] = helperLoadExercise3Baseline(testCase.Paths.BaselineFile);
            baselineResults.SensorDataLog{2}{1}.LookTime = -1;
            file = fullfile(folder.Folder, "misaligned.mat");
            save(file, "baselineResults", "baselineMetadata");
            testCase.verifyError(@() helperLoadExercise3Baseline(file), "Exercise3:InvalidBaseline");
        end

        function rejectShortenedBaseline(testCase)
            folder = testCase.applyFixture(matlab.unittest.fixtures.TemporaryFolderFixture);
            [baselineResults, baselineMetadata] = helperLoadExercise3Baseline(testCase.Paths.BaselineFile);
            baselineResults.Time = baselineResults.Time(1:3);
            baselineResults.OSPA = baselineResults.OSPA(1:3);
            baselineResults.SensorDataLog = baselineResults.SensorDataLog(1:3);
            baselineResults.TruthDataLog = baselineResults.TruthDataLog(1:3);
            file = fullfile(folder.Folder, "shortened.mat");
            save(file, "baselineResults", "baselineMetadata");
            testCase.verifyError(@() helperLoadExercise3Baseline(file), "Exercise3:InvalidBaseline");
        end

        function protectExistingBaseline(testCase)
            before = dir(testCase.Paths.BaselineFile);
            previousRandomStream = rng;
            previousFigures = findall(groot, "Type", "figure");
            testCase.verifyError(@() prepareExercise3Baseline(), "Exercise3:BaselineExists");
            after = dir(testCase.Paths.BaselineFile);
            testCase.verifyEqual([after.bytes after.datenum], [before.bytes before.datenum], AbsTol=0);
            testCase.verifyEqual(rng, previousRandomStream, AbsTol=0);
            testCase.verifyEqual(findall(groot, "Type", "figure"), previousFigures);
        end

        function resolveRelocatedWorkshop(testCase)
            folder = testCase.applyFixture(matlab.unittest.fixtures.TemporaryFolderFixture);
            relocatedRoot = fullfile(folder.Folder, "relocated workshop");
            relocatedExercise3 = fullfile(relocatedRoot, "Exercise3");
            mkdir(fullfile(relocatedRoot, "Exercise2"));
            copyfile(testCase.Paths.Exercise3Folder, relocatedExercise3);
            copyfile(testCase.Paths.Exercise2Folder, fullfile(relocatedRoot, "Exercise2", "exercise2_output"));
            testCase.applyFixture(matlab.unittest.fixtures.CurrentFolderFixture(relocatedExercise3));
            previousPath = path;
            testCase.addTeardown(@() path(previousPath));
            clear setupExercise3
            relocatedPaths = setupExercise3();
            testCase.verifyEqual(relocatedPaths.Exercise3Folder, string(relocatedExercise3));
            testCase.verifyTrue(isfile(relocatedPaths.RadarFile));
            results = helperLoadExercise3Baseline(relocatedPaths.BaselineFile);
            testCase.verifySize(results.TruthDataLog, [101 1]);

            % Construct from the relocated root, where no waypoint file exists.
            testCase.applyFixture(matlab.unittest.fixtures.CurrentFolderFixture(relocatedRoot));
            run(relocatedPaths.RadarFile);
            scene = helperCreateWideAreaSurveillanceScenario(radar);
            testCase.verifyEqual(scene.StopTime, 100, AbsTol=0);
            testCase.verifyGreaterThan(numel(scene.Platforms), 5);

        end

        function rejectCurrentFolderHelperConflict(testCase)
            folder = testCase.applyFixture(matlab.unittest.fixtures.WorkingFolderFixture);
            conflictFile = fullfile(folder.Folder, "helperPlotSensorData.m");
            fileID = fopen(conflictFile, "w");
            fileCleanup = onCleanup(@() fclose(fileID));
            fprintf(fileID, "function helperPlotSensorData(varargin)\nend\n");
            clear fileCleanup
            rehash
            testCase.verifyError(@() setupExercise3(), "Exercise3:HelperConflict");
        end
    end

end

function closeNewFigures(previousFigures)
newFigures = setdiff(findall(groot, "Type", "figure"), previousFigures);
close(newFigures);
end
