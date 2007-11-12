// This file has 136 source lines of code (SLOC).
// This file has 6  comment lines of code (CLOC).
// It calls 7 MPI routines: Status=1, Init=1, Comm_size=1, Comm_rank=1,
// Abort=2, Wtime=2, Finalize=1
// It calls 2 MPI global variables: COMM_WORLD=4, SUCCESS=1

// All together, file contains 9 unique MPI constructs.


#include <sstream>
#include <fstream>
#include <string>
#include <vector>
#include <math.h>
#include "mpi.h"
#include "point.h"
#include "topology.h"

#define X_COORD_LOAD 5
#define Y_COORD_LOAD 2
#define X_COORD_UPPER 0
#define Y_COORD_UPPER 5
#define X_COORD_LOWER 0
#define Y_COORD_LOWER 0

#define MAX_X X_COORD_LOAD
#define MAX_Y Y_COORD_UPPER
#define TOTAL_ROWS MAX_Y + 1

#define MASTER 0
#define FROM_MASTER 1
#define FROM_WORKER 2

double numTopologies = 0;
double numTest(0.0 + 0.0);

string IntToString(int num) {
  ostringstream myStream; 
  myStream << num << flush;
  return(myStream.str()); 
}

void permuteUpperTruss(int x, vector<Point> &path,
                       vector< vector<Point> > &allPaths,
                       int &startY, int &endY, const int isFirst) {
  vector<Point> prevPath(path);
  if (x >= MAX_X) {
    if (path.size() > 1) { 
      path.push_back(Point(X_COORD_LOAD, Y_COORD_LOAD));
      allPaths.push_back(path);
    }
    return;
  }
  permuteUpperTruss(x + 1, path, allPaths, startY, endY, isFirst);
  int firstY = isFirst ? startY : Y_COORD_LOWER;
  int lastY = isFirst ? endY : TOTAL_ROWS;
  for (int y = firstY; y < lastY; y++) {
    path = prevPath;
    path.push_back(Point(x, y));
    permuteUpperTruss(x + 1, path, allPaths, startY, endY, 0);
  }
}

void permuteLowerTruss(int x, vector<Point> &upperPath,
                       vector<Point> &lowerPath,
                       vector<Topology> &topologies) {
  vector<Point> prevPath(lowerPath);
  if (x >= MAX_X) {
    lowerPath.push_back(Point(X_COORD_LOAD, Y_COORD_LOAD));
    numTopologies += 1;
    return;
  }
  permuteLowerTruss(x + 1, upperPath, lowerPath, topologies);
  for (int y = 0; y < TOTAL_ROWS; y++) {
    lowerPath = prevPath;
    lowerPath.push_back(Point(x, y));
    permuteLowerTruss(x + 1, upperPath, lowerPath, topologies);
  }
}

void generateAllTopologies(Point &upperAttachment, Point &lowerAttachment,
                           Point &load, vector<Topology> &topologies,
                           int &startY, int &endY) {
  vector< vector<Point> > allUpperTrusses;
  vector<Point> upperTruss;
  vector<Point> lowerTruss;
  upperTruss.push_back(upperAttachment);
  permuteUpperTruss(1, upperTruss, allUpperTrusses, startY, endY, 1);
  for (int i = 0; i < allUpperTrusses.size(); i++) {
    lowerTruss.clear();
    lowerTruss.push_back(lowerAttachment);
    permuteLowerTruss(1, allUpperTrusses[i], lowerTruss, topologies);
  }
}

int main(int argc, char* argv[]) {
  int i, j, k, fileIndex(0),
    pathLength,
    minimumPosition(-1),
    numtasks,
    taskid,
    numworkers,
    averow,
    startRow,
    endRow,
    source,
    dest,
    mtype,
    rc;

  double div1, div2, result, startTime, finishTime, generationTime, solveTime;
 
  MPI_Status status;

  rc = MPI_Init(&argc, &argv);
  rc|= MPI_Comm_size(MPI_COMM_WORLD, &numtasks);
  rc|= MPI_Comm_rank(MPI_COMM_WORLD, &taskid);
  if (rc != MPI_SUCCESS) {
    cout << "Error initializing MPI and obtaining task ID information.\n";
    MPI_Abort(MPI_COMM_WORLD, rc);
  }

  startTime = MPI_Wtime();
  vector <Topology> allTopologies;
  vector <Point> path;
  Point upperAttach(X_COORD_UPPER, Y_COORD_UPPER);
  Point lowerAttach(X_COORD_LOWER, Y_COORD_LOWER);
  Point load(X_COORD_LOAD, Y_COORD_LOAD);  
  numworkers = numtasks - 1;
  div1 = TOTAL_ROWS;
  div2 = numworkers;
  result = div1 / div2;
  averow = (int)floor(result);


  if (numworkers > TOTAL_ROWS) {
    cout << "A " << TOTAL_ROWS << " row mesh can not be solved by more than " 
         << TOTAL_ROWS << " worker processors (1 row per processor).\n";
    MPI_Abort(MPI_COMM_WORLD, rc);
  }


  if (numtasks == 1) {
    startRow = 0; 
    endRow = TOTAL_ROWS;
  }
  else {
    startRow = (taskid == MASTER) ? averow * numworkers : (taskid-1) * averow;
    endRow = (taskid == MASTER) ? TOTAL_ROWS : startRow + averow;
  }

  if (startRow != endRow) {
    generateAllTopologies(upperAttach, lowerAttach, load, allTopologies,
                          startRow, endRow);
  }

  generationTime = MPI_Wtime();

  if (taskid > MASTER) {
    cout << "P" << taskid << ": Topology generation time: " 
         << generationTime - startTime << endl;
    cout << "Number of topologies generated = " << numTopologies << endl;
  }

  MPI_Finalize();
}


