import subprocess
import os
import shutil
from multiprocessing.pool import ThreadPool
import numpy as np


juliet_path = "./test/Juliet/"
juliet_report_path = "./jreports/"
juliet_testcases_path = "../Juliet/testcases/"
CWEs = ["121", "242"]


results = []

PROCS_FOR_LARGE = 1
LARGE_SIZE = 20000
SKIP_LARGE = False
THREADS = 4
C_CASES_ONLY = True


def main():
    # compile_datalog()
    evaluate_full("242")


# get report of current soufflé run
def get_report(badgood, filename, output_dir):

    testcase = filename.replace(".bc", "").replace(".ll", "").replace("-bad", "").replace("-good", "")

    with open(output_dir+"/print_vulnerable.csv") as csv_file:
        output = list()
        csv_reader = csv_file.readlines()
        for row in csv_reader:
            newLine = testcase+";"+badgood+";"+row
            output.append(newLine)
    return output


# run one testcase
def run_file(cwe, badgood, filename, id, total, processes):
    percentage = str(round(100*id/total))
    id = str(id)
    facts_dir = "facts/"+id
    output_dir = "output/"+id
    filepath = juliet_path+"CWE"+cwe+"/"+badgood+"/"+filename

    if(os.path.getsize(filepath) > LARGE_SIZE):
        processes = str(PROCS_FOR_LARGE)
        if(SKIP_LARGE):
            print("Skipped: "+filename+" id:"+id)
            return ""

    # create folders
    if(not os.path.isdir(output_dir)):
        os.mkdir(output_dir)

    if(not os.path.isdir(facts_dir)):
        os.mkdir(facts_dir)

    # parse
    command_parse = "python3 Parser.py "+filepath+" "
    command_parse += "-o "+facts_dir
    subprocess.call(command_parse, shell=True)

    # run
    command = "bin/analyzer "+filepath+" "
    command += "-F "+facts_dir+" "
    command += "-D "+output_dir+" "
    command += "-j "+processes+" "
    subprocess.call(command, shell=True)
    report = get_report(badgood, filename, output_dir)
    print("Analysis successful "+filename+" || id:"+id+" ["+badgood+":"+percentage+"%]")

    # clean up directories
    if(os.path.isdir(facts_dir)):
        shutil.rmtree(facts_dir)
    if(os.path.isdir(output_dir)):
        shutil.rmtree(output_dir)
    return report


def compile_datalog():
    print("Compiling Datalog...")
    command = "souffle \"logic/main.dl\" -o bin/analyzer"
    subprocess.call(command, shell=True)
    print("Datalog compiled.")


# add .bc ending to bitcodefiles and decompile to .ll files
def preprocess_folder(folder):
    for subdir, dirs, files in os.walk(folder):
        for filename in files:
            filepath = folder + filename
            if(not filename.endswith(".bc") and not filename.endswith(".ll")):
                os.rename(filepath, filepath+".bc")

    for subdir, dirs, files in os.walk(folder):
        for filename in files:
            filepath = folder + filename
            if(filename.endswith(".bc") and not os.path.isfile(str(filepath)[:-3]+".ll")):
                os.system("llvm-dis-10 "+filepath)
    print("Preprocessing successfully finished")


def collect_reports(report):
    global results
    results.extend(report)


# run all testcases (good OR bad) of one CWE
def run_cwe(cwe, badgood):
    global results

    results = []
    cwe_dir = juliet_path+"CWE"+cwe+"/"
    badgood_dir = cwe_dir+badgood+"/"

    preprocess_folder(badgood_dir)

    file_list = list()
    c_file_list = list()
    found_list = list()

    # create file list
    file_list_file = cwe_dir+"filelist_CWE"+cwe+".csv"
    if(C_CASES_ONLY and os.path.exists(file_list_file)):
        with open(file_list_file) as csv_file:
            lines = csv_file.readlines()
            # print(lines)

            for line in lines:
                line = line.replace("\n", "")
                c_file_list.append(line+"-"+badgood+".ll")

    for subdir, dirs, files in os.walk(badgood_dir):
        for filename in files:
            if(filename.endswith(".ll")):
                filepath = badgood_dir + filename
                if(os.path.getsize(filepath) > LARGE_SIZE and SKIP_LARGE):
                    continue
                file_list.append(filename)

    # print("fl:"+str(len(file_list)))
    # print("cfl:"+str(len(c_file_list)))

    if(C_CASES_ONLY):
        file_list = list(set(file_list) & set(c_file_list))

    # print("fl:"+str(len(file_list)))

    file_list.sort()

    # run analysis in parallel
    pool = ThreadPool(THREADS)
    [pool.apply_async(run_file, args=(cwe, badgood, filename, id+1, len(file_list), "1"), callback=collect_reports)
     for id, filename in enumerate(file_list)]
    pool.close()
    pool.join()
    print("All "+badgood+" files processed")

    for res in results:
        lines = res.split("\n")
        for line in lines:
            split = line.split(";")
            filename = split[0]
            filename = filename + "-"+badgood+".ll"
            found_list.append(filename)

    # create final report
    full_report_str = "".join(results)
    if(badgood == "bad"):
        with open(juliet_report_path+'jreport_cwe'+cwe+'_vulns.csv', mode='w') as report:
            report.write(full_report_str)
        false_negative_list = np.setdiff1d(file_list, found_list)
        false_negatives_str = "\n".join(false_negative_list)
        with open(juliet_report_path+'jreport_cwe'+cwe+'_fn.csv', mode='w') as report:
            report.write(false_negatives_str)

        num_total = len(file_list)
        num_vulns = len(results)
        num_false_neg = len(false_negative_list)
        num_true_positives = num_total-num_false_neg
        num_false_positives = num_vulns-num_true_positives
        return(num_total, num_vulns, num_false_neg, num_true_positives, num_false_positives)

    elif(badgood == "good"):
        with open(juliet_report_path+'jreport_cwe'+cwe+'_fp.csv', mode='w') as report:
            report.write(full_report_str)

        num_total = len(file_list)
        num_vulns = -1
        num_false_neg = -1
        num_true_positives = -1
        num_false_positives = len(results)
        return(num_total, num_vulns, num_false_neg, num_true_positives, num_false_positives)


def evaluate_good(cwe, show=True):
    print("Processing CWE"+cwe+" good")
    num_total, num_vulns, num_false_neg, num_true_positives, num_false_positives = run_cwe(cwe, "good")

    if(show):
        print("\n")
        print("CWE: "+str(cwe))
        print("Testcases: "+str(num_total))
        print("False Positives (in patched): "+str(num_false_positives))

    return(num_total, num_vulns, num_false_neg, num_true_positives, num_false_positives)


def evaluate_bad(cwe, show=True):
    print("Processing CWE"+cwe+" bad")
    num_total, num_vulns, num_false_neg, num_true_positives, num_false_positives = run_cwe(cwe, "bad")

    if(show):
        print("\n")
        print("CWE: "+str(cwe))
        print("Testcases: "+str(num_total))
        print("Vulns: "+str(num_vulns))
        print("True Positives: "+str(num_true_positives)+" ["+str(round(100*num_true_positives/num_total))+"%]")
        print("False Negatives: "+str(num_false_neg)+" ["+str(round(100*num_false_neg/num_total))+"%]")
        print("False Positives (in vulnerable): "+str(num_false_positives))

    return(num_total, num_vulns, num_false_neg, num_true_positives, num_false_positives)


def evaluate_full(cwe):
    num_total, num_vulns, num_false_neg, num_true_positives, num_bad_false_positives = evaluate_bad(cwe, False)
    _, _, _, _, num_good_false_positives = evaluate_good(cwe, False)

    print("\n")
    print("CWE: "+str(cwe))
    print("Testcases: "+str(num_total))
    print("Vulns: "+str(num_vulns))
    print("True Positives: "+str(num_true_positives)+" ["+str(round(100*num_true_positives/num_total))+"%]")
    print("False Negatives: "+str(num_false_neg)+" ["+str(round(100*num_false_neg/num_total))+"%]")
    print("False Positives (in vulnerable): "+str(num_bad_false_positives))
    print("False Positives (in patched): "+str(num_good_false_positives))


def evaluate_all_cwes():
    for cwe in CWEs:
        evaluate_full(cwe)


if __name__ == "__main__":
    main()
