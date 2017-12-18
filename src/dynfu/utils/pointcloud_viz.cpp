#include <dynfu/utils/pointcloud_viz.hpp>

PointCloudViz::PointCloudViz() { this->viewer = std::make_shared<cv::viz::Viz3d>("PointCloud"); }

std::shared_ptr<cv::viz::Viz3d> PointCloudViz::getViewer() { return this->viewer; }

cv::Mat PointCloudViz::vecToMat(std::vector<cv::Vec3f> vec) {
    int rows = vec.size();
    cv::Mat res(rows, 1, CV_32FC3);
    for (int x = 0; x < rows; ++x) {
        res.at<cv::Vec3f>(x, 0) = vec[x];
    }
    return res;
}

cv::viz::WCloud PointCloudViz::matToCloud(cv::Mat mat) { return cv::viz::WCloud(mat, cv::viz::Color::white()); }
